import 'package:playing_tracker/features/classes/domain/models/membership_model.dart';

/// Resultado de paginación para miembros de una clase.
typedef MembershipPage = ({
  List<MembershipModel> members,
  String? lastDocumentId,
});
