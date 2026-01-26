/// Strings relacionados con clases
class ClassesStrings {
  // Títulos de pantallas
  static const String myClassesTitle = 'Mis clases';
  static const String classesCreatedTitle = 'Clases creadas';
  static const String classesTitle = 'Clases';

  // Acciones
  static const String createClass = 'Crear clase';
  static const String createNewClass = 'Crear nueva clase';
  static const String joinClass = 'Unirse a clase';
  static const String joinClassAction = 'Unirse a clase';

  // Estados vacíos - Docente
  static const String noClassesCreated = 'No tienes clases creadas';
  static const String createFirstClass = 'Crea tu primera clase para comenzar';

  // Estados vacíos - Estudiante
  static const String noClassesJoined = 'No estás en ninguna clase';
  static const String joinClassWithCode = 'Únete a una clase con un código';

  // Información de clases
  static const String studentsCount = 'estudiantes';
  static const String teacherLabel = 'Profesor: ';

  // Crear clase
  static const String createClassTitle = 'Crear nueva clase';
  static const String classNameLabel = 'Nombre de la clase';
  static const String classNameHint = 'Ej: Piano Nivel 1';
  static const String classDescriptionLabel = 'Descripción';
  static const String classDescriptionHint = 'Descripción de la clase';
  static const String accessCodeLabel = 'Código de acceso';
  static const String accessCodeGenerated = 'Se generará automáticamente';
  static const String accessCodeValueLabel = 'Código';
  static const String accessCodeInvalidFormat =
      'El código debe tener 6 caracteres válidos';
  static const String createClassButton = 'Crear clase';
  static const String classStatusActive = 'Clase activa';
  static const String classStatusArchived = 'Clase archivada';
  static const String archiveClassAction = 'Archivar clase';
  static const String activateClassAction = 'Activar clase';
  static const String deleteClassAction = 'Eliminar clase';
  static const String deleteClassConfirmation =
      'Esta acción eliminará definitivamente la clase y todas sus membresías.';
  static const String regenerateAccessCodeAction = 'Regenerar código';
  static const String regenerateCodeConfirmation =
      'Generaremos un nuevo código y el anterior dejará de funcionar.';

  // Unirse a clase
  static const String joinClassTitle = 'Unirse a una clase';
  static const String accessCodeHint = 'Ingresa el código de la clase';
  static const String accessCodeInstructions =
      'Pide el código de acceso a tu profesor para unirte a la clase.';
  static const String joinButton = 'Unirse';

  // Mensajes operativos
  static const String classGenericError =
      'Ocurrió un error al gestionar tus clases.';
  static const String classCreateSuccess = 'Clase creada correctamente.';
  static const String classStatusUpdatedSuccess =
      'El estado de la clase se actualizó correctamente.';
  static const String classDeleteSuccess =
      'La clase fue eliminada correctamente.';
  static const String membershipGenericError =
      'Ocurrió un error al gestionar las membresías.';
  static const String membershipInviteSuccess =
      'Alumno agregado correctamente.';
  static const String membershipJoinSuccess =
      'Te uniste a la clase correctamente.';
  static const String membershipRemoveSuccess =
      'Alumno removido correctamente.';
  static const String membershipActivateSuccess =
      'Alumno activado correctamente.';
  static const String membershipDeactivateSuccess =
      'Alumno inactivado correctamente.';
  static const String membershipDeleteSuccess =
      'La membresía se eliminó definitivamente.';
  static const String membershipRegenerateSuccess =
      'Código de acceso regenerado correctamente.';
  static const String membershipDeleteConfirmation =
      'Esta acción eliminará de forma permanente al alumno de la clase.';
  static const String membershipRevokedError =
      'Fuiste eliminado de esta clase. Contacta al profesor para reingresar.';
}
