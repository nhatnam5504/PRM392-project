class ApiConstants {
  ApiConstants._();

  // BASE — production Swagger API
  static const baseUrl = 'https://tgdd-api.kdz.asia';

  // ─── User Service ─────────────────────────────
  // Account endpoints
  static const users = '/api/users';
  static const userById = '/api/users'; // + /{id}
  static const userName = '/api/users'; // + /{id}/name

  // Auth endpoints
  static const authLogin = '/api/users/auth/login';

  // Role endpoints
  static const roles = '/api/users/roles';
  static const permissions = '/api/users/roles/permissions';

  // Health
  static const userHealth = '/api/users/health';

  // ─── Product Service ──────────────────────────
  // Product endpoints
  static const products = '/api/products/product';
  static const productById = '/api/products/product'; // + /{id}
  static const productsByBrand = '/api/products/product/brand'; // + /{brandId}
  static const productsByCategory =
      '/api/products/product/category'; // + /{categoryId}
  static const activeProducts = '/api/products/product/active';
  static const inactiveProducts = '/api/products/product/inactive';

  // Category endpoints
  static const categories = '/api/products/categories';
  static const categoryById = '/api/products/categories'; // + /{id}

  // Brand endpoints
  static const brands = '/api/products/brands';
  static const brandById = '/api/products/brands'; // + /{id}

  // Product Version endpoints
  static const productVersions = '/api/products/product-versions';

  // Health
  static const productHealth = '/api/products/health';

  // ─── Legacy (kept for compatibility) ──────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const refreshToken = '/auth/refresh';
  static const googleLogin = '/auth/google';
  static const forgotPassword = '/auth/forgot-password';
  static const verifyOtp = '/auth/verify-otp';
  static const resetPassword = '/auth/reset-password';
  static const profile = '/users/me';
  static const updateProfile = '/users/me';
  static const uploadAvatar = '/users/me/avatar';
  static const changePassword = '/users/me/change-password';
  static const addresses = '/users/me/addresses';
  static const searchProducts = '/products/search';
  static const featuredProducts = '/products/featured';
  static const flashSaleProducts = '/products/flash-sale';
  static const banners = '/banners';
  static const cart = '/cart';
  static const orders = '/orders';
  static const cancelOrder = '/orders/:id/cancel';
  static const submitReview = '/reviews';
  static const validateVoucher = '/vouchers/validate';
  static const wishlist = '/wishlist';
  static const membershipPoints = '/membership/points';
  static const redeemPoints = '/membership/redeem';
  static const pointsHistory = '/membership/history';
  static const promotions = '/promotions';

  // ─── Order Service — Promotions ───────────────
  static const orderPromotions =
      '/api/orders/promotions';
}
