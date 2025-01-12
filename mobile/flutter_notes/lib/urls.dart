
const String baseUrl = "http://127.0.0.1:8000/api"; 
// For iOS simulator, use "http://localhost:8000"
// For a real device, replace with your machine's IP, e.g., "http://192.168.x.x:8000"

Uri retrieveUrl = Uri.parse("$baseUrl/notes/");
Uri createUrl = Uri.parse("$baseUrl/notes/create/");
Uri updateUrl(int id) => Uri.parse("$baseUrl/notes/$id/update/");
Uri deleteUrl(int id) => Uri.parse("$baseUrl/notes/$id/delete/");
