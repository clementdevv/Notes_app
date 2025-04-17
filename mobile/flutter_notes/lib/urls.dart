
const String baseUrl = "http://127.0.0.1:8000/api"; 


Uri retrieveUrl = Uri.parse("$baseUrl/notes/");
Uri createUrl = Uri.parse("$baseUrl/notes/create/");
Uri updateUrl(int id) => Uri.parse("$baseUrl/notes/$id/update/");
Uri deleteUrl(int id) => Uri.parse("$baseUrl/notes/$id/delete/");
