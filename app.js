const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const app = express();

// Initialize Firebase
const serviceAccount = require('./your-firebase-key.json'); // Path to your Firebase private key

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://your-database-name.firebaseio.com', // Replace with your Firebase DB URL
});

// Get a reference to the Firestore database
const db = admin.firestore();

// Middleware to parse POST data
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files (CSS, images, etc.)
app.use(express.static('public'));

// Home route
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

// Registration route (to handle form submission)
app.post('/register', async (req, res) => {
    const { name, email, password } = req.body;

    // Validation checks
    if (!name || !email || !password) {
        return res.send('<h2>Error: All fields are required!</h2>');
    }

    // Simple email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return res.send('<h2>Error: Invalid email format!</h2>');
    }

    // Enhanced password validation
    const passwordRegex = /^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{6,}$/;
    if (!passwordRegex.test(password)) {
        return res.send('<h2>Error: Incorrect password type! Password must be at least 6 characters long, contain at least one uppercase letter, and one number.</h2>');
    }

    // Store user data in Firestore
    try {
        const userRef = db.collection('users').doc(email); // Use email as the document ID
        await userRef.set({
            name: name,
            email: email,
            password: password,  // In real-world, hash passwords before storing them
        });
        
        console.log('User registered successfully:', { name, email, password });

        // Send a success message
        res.send(`<h2>Thank you for registering, ${name}!</h2>`);

    } catch (error) {
        console.error('Error adding document:', error);
        res.send('<h2>Error: There was an issue with registration. Please try again later.</h2>');
    }
});

// Start the server
const port = 3000;
app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
