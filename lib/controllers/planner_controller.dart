import 'package:flutter_notes_app/models/planner.dart';
import 'package:flutter_notes_app/services/database_service.dart';
import 'package:get/get.dart';

class PlannerController extends GetxController {
  final _db = DatabaseService.instance;
  final planners = <Planner>[].obs;

  Future<void> loadPlanners(int userId) async {
    final plannerList = await _db.getPlanners(userId);
    planners.assignAll(plannerList);
  }

  Future<void> addPlanner(Planner planner) async {
    final newPlanner = await _db.createPlanner(planner);
    planners.insert(0, newPlanner);
  }

  Future<void> updatePlanner(Planner planner) async {
    await _db.updatePlanner(planner);
    final index = planners.indexWhere((p) => p.id == planner.id);
    if (index != -1) {
      planners[index] = planner;
    }
  }

  Future<void> deletePlanner(int id) async {
    await _db.deletePlanner(id);
    planners.removeWhere((planner) => planner.id == id);
  }

  Future<void> toggleComplete(Planner planner) async {
    final updatedPlanner = Planner(
      id: planner.id,
      userId: planner.userId,
      title: planner.title,
      description: planner.description,
      date: planner.date,
      isCompleted: !planner.isCompleted,
    );
    await updatePlanner(updatedPlanner);
  }
}