/**
 * Cloud Functions - Playing Tracker
 *
 * Funciones de backend para asignar Custom Claims de rol a los usuarios
 * de Firebase Authentication en el momento de creación de su perfil.
 *
 * Al añadir un Custom Claim al token JWT, las reglas de seguridad de
 * Firestore pueden validar el rol sin necesidad de lecturas adicionales
 * (eliminando el coste de exists() en isTeacher() / isStudent()).
 */

import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

// Inicialización del Admin SDK (usa las credenciales del entorno Firebase)
initializeApp();

// ============================================================================
// TRIGGER: Asignar rol 'teacher' cuando se crea un perfil de docente
// ============================================================================
// Se dispara cuando un nuevo documento es creado en la colección /teachers/{userId}
// Solo se necesita una vez por usuario; el claim persiste en su token JWT.

export const onTeacherProfileCreated = onDocumentCreated(
    {
        document: "teachers/{userId}",
        region: "europe-southwest1",
        memory: "256MiB",
    },
    async (event) => {
        const userId = event.params.userId;

        if (!userId) {
            console.error("onTeacherProfileCreated: userId no encontrado en el evento.");
            return;
        }

        try {
            await getAuth().setCustomUserClaims(userId, { role: "teacher" });
            console.log(`✅ Custom Claim 'teacher' asignado al usuario: ${userId}`);
        } catch (error) {
            console.error(`❌ Error al asignar claim 'teacher' a ${userId}:`, error);
        }
    }
);

export const onStudentProfileCreated = onDocumentCreated(
    {
        document: "students/{userId}",
        region: "europe-southwest1",
        memory: "256MiB",
    },
    async (event) => {
        const userId = event.params.userId;

        if (!userId) {
            console.error("onStudentProfileCreated: userId no encontrado en el evento.");
            return;
        }

        try {
            await getAuth().setCustomUserClaims(userId, { role: "student" });
            console.log(`✅ Custom Claim 'student' asignado al usuario: ${userId}`);
        } catch (error) {
            console.error(`❌ Error al asignar claim 'student' a ${userId}:`, error);
        }
    }
);
