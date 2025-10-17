import 'api_service.dart';
import '../models/course.dart';

class CourseService {
  final ApiService _apiService = ApiService();

  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final response = await _apiService.client.get('/courses/');
      final data = response.data as List;
      return data.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  // Get a specific course by ID
  Future<Course> getCourse(int id) async {
    try {
      final response = await _apiService.client.get('/courses/$id');
      return Course.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching course $id: $e');
    }
  }

  // Create a new course
  Future<Course> createCourse(String name, String code) async {
    try {
      final response = await _apiService.client.post(
        '/courses/',
        data: {
          'name': name,
          'code': code,
        },
      );
      return Course.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating course: $e');
    }
  }

  // Update an existing course
  Future<Course> updateCourse(int id, String name, String code) async {
    try {
      final response = await _apiService.client.put(
        '/courses/$id',
        data: {
          'name': name,
          'code': code,
        },
      );
      return Course.fromJson(response.data);
    } catch (e) {
      throw Exception('Error updating course $id: $e');
    }
  }

  // Delete a course
  Future<void> deleteCourse(int id) async {
    try {
      await _apiService.client.delete('/courses/$id');
    } catch (e) {
      throw Exception('Error deleting course $id: $e');
    }
  }
}
