class AppConfig {
  // Development - Use your Mac's IP address when testing on physical iPhone
  // Find it with: ifconfig | grep "inet " | grep -v 127.0.0.1
  static const String devApiBaseUrl = 'http://192.168.1.6:8080';
  static const String devWebSocketUrl = 'ws://192.168.1.6:8080/ws';
  
  // Production (update when deploying)
  static const String prodApiBaseUrl = 'https://api.trazzo.com';
  static const String prodWebSocketUrl = 'wss://api.trazzo.com/ws';
  
  // Environment flag
  static const bool isProduction = false;
  
  // Get current API base URL
  static String get apiBaseUrl => isProduction ? prodApiBaseUrl : devApiBaseUrl;
  
  // Get current WebSocket URL
  static String get webSocketUrl => isProduction ? prodWebSocketUrl : devWebSocketUrl;
  
  // API timeout duration (in seconds)
  static const int apiTimeoutSeconds = 30;
  
  // Token expiry buffer (refresh token before expiry)
  static const int tokenRefreshBufferSeconds = 300; // 5 minutes

  // UPI Pay on delivery - your personal VPA for receiving payments
  // Set your UPI ID (e.g. you@paytm, you@ybl, you@okaxis) and display name
  static const String upiVpa = 'YOUR_UPI_ID@paytm'; // e.g. john.doe@paytm
  static const String upiPayeeName = 'Trazzo'; // Name shown to customer in UPI app
}
