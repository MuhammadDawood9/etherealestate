abstract final class AppRoutes {
  static const login          = '/login';
  static const signup         = '/signup';
  static const feed           = '/feed';
  static const search         = '/search';
  static const map            = '/map';
  static const collection     = '/collection';
  static const profile        = '/profile';
  static const agent          = '/agent';
  static const admin          = '/admin';
  // Dynamic: /property/<propertyId>  — handled via onGenerateRoute
  static const propertyDetail = '/property';
}
