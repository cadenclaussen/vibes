#!/usr/bin/env node
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// look for service account key
const serviceAccountPath = resolve(__dirname, 'serviceAccountKey.json');
if (!existsSync(serviceAccountPath)) {
    console.error('Error: serviceAccountKey.json not found');
    console.error('');
    console.error('To get this file:');
    console.error('1. Go to Firebase Console > Project Settings > Service Accounts');
    console.error('2. Click "Generate new private key"');
    console.error('3. Save as scripts/serviceAccountKey.json');
    process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

initializeApp({
    credential: cert(serviceAccount)
});

const auth = getAuth();
const db = getFirestore();

async function deleteAllUsers() {
    console.log('Fetching all users from Firebase Auth...');

    let deletedCount = 0;
    let nextPageToken;

    do {
        const listResult = await auth.listUsers(1000, nextPageToken);
        const uids = listResult.users.map(user => user.uid);

        if (uids.length === 0) {
            break;
        }

        console.log(`Found ${uids.length} users, deleting...`);

        // delete from Auth
        const deleteResult = await auth.deleteUsers(uids);
        deletedCount += deleteResult.successCount;

        if (deleteResult.failureCount > 0) {
            console.error(`Failed to delete ${deleteResult.failureCount} users`);
            deleteResult.errors.forEach(err => {
                console.error(`  - ${err.error.message}`);
            });
        }

        // delete from Firestore
        console.log('Deleting user documents from Firestore...');
        const batch = db.batch();
        for (const uid of uids) {
            batch.delete(db.collection('users').doc(uid));
        }
        await batch.commit();

        nextPageToken = listResult.pageToken;
    } while (nextPageToken);

    console.log(`Deleted ${deletedCount} users from Auth`);
}

async function deleteCollection(collectionName) {
    console.log(`Deleting all documents from ${collectionName}...`);

    const collectionRef = db.collection(collectionName);
    const batchSize = 500;
    let deletedCount = 0;

    while (true) {
        const snapshot = await collectionRef.limit(batchSize).get();

        if (snapshot.empty) {
            break;
        }

        const batch = db.batch();
        snapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });
        await batch.commit();
        deletedCount += snapshot.size;
    }

    console.log(`Deleted ${deletedCount} documents from ${collectionName}`);
    return deletedCount;
}

async function main() {
    console.log('=== Firebase User Deletion Script ===');
    console.log('');

    try {
        // delete all Auth users and their Firestore profiles
        await deleteAllUsers();

        // delete related collections
        await deleteCollection('friendships');
        await deleteCollection('songShares');
        await deleteCollection('messages');
        await deleteCollection('messageThreads');

        console.log('');
        console.log('Done! All users and related data deleted.');
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

main();
