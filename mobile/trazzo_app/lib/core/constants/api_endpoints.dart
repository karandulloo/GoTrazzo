class ApiEndpoints {
  // Base URL is set in AppConfig
  
  // Authentication
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  
  // Customer
  static const String customerProfile = '/api/customer/profile';
  static const String nearbyBusinesses = '/api/customer/businesses/nearby';
  static String businessDetails(int id) => '/api/customer/businesses/$id';
  
  // Business
  static const String updateBusinessProfile = '/api/business/profile';
  static const String getBusinessProfile = '/api/business/profile';
  
  // Chat
  static const String createChat = '/api/chat/create';
  static String chatMessages(int chatId) => '/api/chat/$chatId/messages';
  static String userChats(int userId) => '/api/chat/user/$userId';
  static const String sendMessage = '/api/chat/send';
  
  // Orders
  static const String orders = '/api/orders';
  static const String ordersFromOffer = '/api/orders/from-offer';
  static String orderDetails(int orderId) => '/api/orders/$orderId';
  static String orderItems(int orderId) => '/api/orders/$orderId/items';
  static String confirmOrder(int orderId) => '/api/orders/$orderId/confirm';
  static String orderPayment(int orderId) => '/api/orders/$orderId/payment';
  static String customerOrders(int customerId) => '/api/orders/customer/$customerId';
  static String businessOrders(int businessId) => '/api/orders/business/$businessId';
  static String riderOrders(int riderId) => '/api/orders/rider/$riderId';
  
  // Rider
  static String riderStatus(int riderId) => '/api/rider/$riderId/status';
  static String riderLocation(int riderId) => '/api/rider/$riderId/location';
  static String acceptOrder(int orderId) => '/api/rider/orders/$orderId/accept';
  static String markDelivered(int orderId) => '/api/rider/orders/$orderId/deliver';
  
  // WebSocket
  static const String webSocketSend = '/app/chat.send';
  static String webSocketTopic(int chatId) => '/topic/chat/$chatId';
}
