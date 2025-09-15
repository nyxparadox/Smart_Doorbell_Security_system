
#include <WiFiClientSecure.h>
#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "time.h"

// WiFi credentials
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// for time and date
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 19800; // For IST (GMT+5:30), use 19800 seconds
const int daylightOffset_sec = 0;

// Cloudinary API
const char* cloudinary_host = "api.cloudinary.com";
const int cloudinary_port = 443; // HTTPS
const char* cloudinary_path = "/v1_1/<YOUR_CLOUD_NAME>/image/upload";
const char* upload_preset = "<YOUR_CLOUDINARY_UPLOAD_PRESET>";

// Firestore settings
const char* firestore_host = "https://firestore.googleapis.com/v1/projects/<YOUR_FIREBASE_PROJECT_ID>/(default)/documents/visitors?key=<YOUR_FIREBASE_API_KEY>";

#define BUTTON_PIN 14
bool lastButtonState = HIGH;

// Global variables to reduce stack usage
WiFiClientSecure client;
camera_fb_t* fb = nullptr;
String cloudinaryResponse = "";

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Starting ESP32 Camera...");
  
  pinMode(BUTTON_PIN, INPUT_PULLUP);

  // Connect to WiFi
  Serial.print("Connecting to WiFi");
  WiFi.begin(ssid, password);
  int wifiAttempts = 0;
  while (WiFi.status() != WL_CONNECTED && wifiAttempts < 20) {
    delay(500);
    Serial.print(".");
    wifiAttempts++;
  }
  
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nWiFi connection failed! Restarting...");
    ESP.restart();
  }
  
  Serial.println("\nWiFi connected!");

  // Initialize camera with minimal settings
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = 5;
  config.pin_d1 = 18;
  config.pin_d2 = 19;
  config.pin_d3 = 21;
  config.pin_d4 = 36;
  config.pin_d5 = 39;
  config.pin_d6 = 34;
  config.pin_d7 = 35;
  config.pin_xclk = 0;
  config.pin_pclk = 22;
  config.pin_vsync = 25;
  config.pin_href = 23;
  config.pin_sscb_sda = 26;
  config.pin_sscb_scl = 27;
  config.pin_pwdn = 32;
  config.pin_reset = -1;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  
  // Use very conservative settings to avoid memory issues
  if (psramFound()) {
    Serial.println("PSRAM found");
    config.frame_size = FRAMESIZE_VGA;    // Medium size
    config.jpeg_quality = 10;             // Good quality
    config.fb_count = 1;                  // Single buffer
  } else {
    Serial.println("PSRAM not found - using minimal settings");
    config.frame_size = FRAMESIZE_SVGA;   // Smaller size
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }
  
  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println(" Camera init failed");
    delay(1000);
    ESP.restart();
  } else {
    Serial.println("Camera initialized");
  }

  // Configure time
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  
  Serial.print("Waiting for time sync");
  int timeAttempts = 0;
  while (!time(nullptr) && timeAttempts < 10) {
    Serial.print(".");
    delay(1000);
    timeAttempts++;
  }
  Serial.println();
  
  Serial.println("Setup complete!");
  Serial.printf("Free heap: %d bytes\n", ESP.getFreeHeap());
}

// Function to get current time in RFC 3339 format for Firestore
String getFirestoreTimestamp() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    // Return a default timestamp if time is not synced
    return "1970-01-01T00:00:00Z"; 
  }
                                                                                 
  // Format the time as an RFC 3339 string
  // This is the format Firestore's timestampValue field expects
  static char timeString[30]; 
  strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%SZ", &timeinfo);
  
  return String(timeString);
}

void printLocalTime() {
  Serial.println(getFirestoreTimestamp());
}

void loop() {
  int buttonState = digitalRead(BUTTON_PIN);
  if (buttonState == LOW && lastButtonState == HIGH) {
    Serial.println("Button pressed!");
    
    delay(50); // Debounce
    if (digitalRead(BUTTON_PIN) == LOW) {
      
      Serial.printf("Free heap before capture: %d bytes\n", ESP.getFreeHeap());
      
      // Run upload in separate task to avoid stack issues
      xTaskCreate(
        captureAndUploadTask,   // Task function
        "upload_task",          // Task name
        8192,                   // Stack size (8KB)
        NULL,                   // Parameters
        1,                      // Priority
        NULL                    // Task handle
      );
      
      // Wait for button release
      while (digitalRead(BUTTON_PIN) == LOW) {
        delay(10);
      }
      delay(2000); // This is for Preventing multiple triggers
    }
  }
  lastButtonState = buttonState;
  delay(50);
}

void captureAndUploadTask(void *parameter) {
  Serial.println("📷 Starting capture task...");
  
  // Capture image
  fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    vTaskDelete(NULL);
    return;
  }
  
  Serial.printf("Image captured: %u bytes\n", fb->len);
  
  if (fb->len < 1000) {
    Serial.println("Image too small");
    esp_camera_fb_return(fb);
    vTaskDelete(NULL);
    return;
  }
  
  // Upload to Cloudinary
  String imageUrl = uploadToCloudinary();
  
  // Free camera buffer
  esp_camera_fb_return(fb);
  fb = nullptr;
  
  if (imageUrl.length() > 0) {
    // Upload to Firestore
    uploadToFirestore(imageUrl);
  }
  
  Serial.println("Task completed");
  Serial.printf("Free heap after task: %d bytes\n", ESP.getFreeHeap());
  
  // Delete this task
  vTaskDelete(NULL);
}

String uploadToCloudinary() {
  Serial.println("🔧 Upload settings:");
  Serial.println("  Host: " + String(cloudinary_host));
  Serial.println("  Path: " + String(cloudinary_path));
  Serial.println("  Preset: " + String(upload_preset));
  
  client.setInsecure();
  client.setTimeout(20000); // 20 second timeout
  
  Serial.println(" Connecting to Cloudinary...");
  if (!client.connect(cloudinary_host, cloudinary_port)) {
    Serial.println("Connection failed");
    return "";
  }
  
  Serial.println(" Connected to Cloudinary");

  // This is for Preparing multipart form data
  String boundary = "----ESP32Boundary";
  String header = "--" + boundary + "\r\n"
                 "Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n" + 
                 String(upload_preset) + "\r\n--" + boundary + "\r\n"
                 "Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n"
                 "Content-Type: image/jpeg\r\n\r\n";
  
  String footer = "\r\n--" + boundary + "--\r\n";
  size_t contentLength = header.length() + fb->len + footer.length();
  
  // Send HTTP request
  client.println("POST " + String(cloudinary_path) + " HTTP/1.1");
  client.println("Host: " + String(cloudinary_host));
  client.println("Content-Type: multipart/form-data; boundary=" + boundary);
  client.println("Content-Length: " + String(contentLength));
  client.println();
  
  // Send header
  client.print(header);
  
  // Here we Send image data in small chunks
  const size_t chunkSize = 1024;
  for (size_t i = 0; i < fb->len; i += chunkSize) {
    size_t len = min(chunkSize, fb->len - i);
    client.write(fb->buf + i, len);
    vTaskDelay(1 / portTICK_PERIOD_MS); // Yield to other tasks
  }
  
  // Send footer
  client.print(footer);
  
  Serial.println("Data sent, waiting for response...");
  
  // Wait for response
  unsigned long timeout = millis();
  while (!client.available() && millis() - timeout < 15000) {
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
  
  if (!client.available()) {
    Serial.println("Response timeout");
    client.stop();
    return "";
  }
  
  // Read response from cloudinary server
  cloudinaryResponse = "";
  bool jsonStarted = false;
  
  while (client.available()) {
    String line = client.readStringUntil('\n');
    line.trim();
    
    if (line.startsWith("{") || jsonStarted) {
      jsonStarted = true;
      cloudinaryResponse += line;
    }
    vTaskDelay(1 / portTICK_PERIOD_MS);
  }
  
  client.stop();
  
  if (cloudinaryResponse.length() == 0) {
    Serial.println(" Empty response");
    return "";
  }
  
  // Parse JSON response
  DynamicJsonDocument doc(1024);
  DeserializationError error = deserializeJson(doc, cloudinaryResponse);
  
  if (error) {
    Serial.println(" JSON parse error: " + String(error.c_str()));
    return "";
  }
  
  if (!doc.containsKey("secure_url")) {
    Serial.println(" No secure_url in response");
    return "";
  }
  
  String url = doc["secure_url"].as<String>();
  Serial.println("Image uploaded: " + url);
  return url;
}

void uploadToFirestore(String imageUrl) {
  Serial.println("Uploading to Firestore...");
  
  HTTPClient http;
  http.begin(firestore_host);
  http.addHeader("Content-Type", "application/json");
  
  // Create JSON payload with proper timestamp format
  DynamicJsonDocument doc(512);
  JsonObject fields = doc.createNestedObject("fields");
  fields["deviceId"]["stringValue"] = "<YOUR_DEVICE_ID>";
  fields["imageUrl"]["stringValue"] = imageUrl;
  fields["timestamp"]["timestampValue"] = getFirestoreTimestamp(); // Changed to timestampValue
  
  String payload;
  serializeJson(doc, payload);
  
  Serial.println("Firestore payload: " + payload);
  
  int httpCode = http.POST(payload);
  
  Serial.printf("Firestore response: %d\n", httpCode);
  if (httpCode == 200) {
    Serial.println("Firestore upload successful");
  } else {
    Serial.println("Firestore upload failed");
    Serial.println("Response: " + http.getString());
  }
  
  http.end();
}