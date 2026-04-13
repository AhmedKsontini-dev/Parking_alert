/**
 * 🚀 Firebase Cloud Function pour Parking Alert
 * Ce script s'exécute sur les serveurs de Google.
 * Il détecte chaque nouvelle alerte et envoie une notification push au destinataire.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendAlertNotification = functions.firestore
    .document('alerts/{alertId}')
    .onCreate(async (snapshot, context) => {
        const alertData = snapshot.data();
        const targetMatricule = alertData.matricule; // La voiture bloquée
        const messageText = alertData.message;
        const senderMatricule = alertData.senderMatricule;

        console.log(`Nouvelle alerte pour ${targetMatricule} de la part de ${senderMatricule}`);

        try {
            // 1. Chercher le token FCM du destinataire dans la collection 'users'
            const userDoc = await admin.firestore().collection('users').doc(targetMatricule).get();

            if (!userDoc.exists) {
                console.log('Utilisateur destinataire non trouvé dans la base.');
                return null;
            }

            const userData = userDoc.data();
            const fcmToken = userData.fcmToken;

            if (!fcmToken) {
                console.log('L\'utilisateur n\'a pas de Token FCM enregistré.');
                return null;
            }

            // 2. Préparer le message de notification
            const payload = {
                notification: {
                    title: 'Alerte Parking 🚗',
                    body: `${senderMatricule} vous signale : "${messageText}"`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
                data: {
                    alertId: context.params.alertId,
                    type: 'parking_alert',
                }
            };

            // 3. Envoyer la notification via FCM
            const response = await admin.messaging().sendToDevice(fcmToken, payload);
            console.log('Notification envoyée avec succès:', response.results);
            return response;

        } catch (error) {
            console.error('Erreur lors de l\'envoi de la notification:', error);
            return null;
        }
    });
