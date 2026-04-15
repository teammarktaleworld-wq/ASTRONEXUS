import admin from "../../service/config/firebase.js";

export async function verifyFirebaseOtp(req, res) {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ error: "Firebase ID token required" });
    }

    const decoded = await admin.auth().verifyIdToken(idToken);

    return res.json({
      success: true,
      firebaseUid: decoded.uid,
      phone: decoded.phone_number,
    });

  } catch (err) {
    return res.status(401).json({ error: "Invalid Firebase token" });
  }
}
