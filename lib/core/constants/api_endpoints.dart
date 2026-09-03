/// Centralized Sitefinity Headless CMS API Endpoints Configuration
class ApiEndpoints {
  ApiEndpoints._();

  // Sitefinity Headless Production Base URL from Postman Collection
  static const String baseUrl = 'https://sitefinityheadlesscmsapi.idealake.com';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Authentication Endpoints
  static const String login = '/sitefinity/oauth/token';
  static const String logout = '/auth/logout';

  // Sitefinity Headless Endpoints from Postman
  static const String contents = '/api/idealake/contents';
  static const String modules = '/api/idealake/modules';

  // OData Filter Constants from Postman Collection
  static const String clientImagesParentId =
      '60bbc6c5-4757-4697-ab6b-003a78c54c0f';
  static const String awardImagesParentId =
      'd7e1016a-bcbb-4e04-bf78-4029b71d7d6a';
  static const String filterWebsiteLogo = "contains(Title,'Website_logo')";
  static const String filterServiceBanner = "contains(Title,'service-banner')";
  static const String filterCareerBanner =
      "contains(Title,'career background desktop')";
  static const String filterPoweredByCenter =
      "contains(Title,'powered by center Image')";
  static const String filterTrailblazingWork =
      "contains(Title,'Trailblazing_Work_Home_Image_2')";


  static const String policies = '/api/idealake/policies';
  static const String documents = '/api/idealake/documents';
  static const String documentLibraries = '/api/idealake/document-libraries';
  static const String idealakeImages = '/api/idealake/images';
  static const String companyServices = '/api/idealake/contents';
}
