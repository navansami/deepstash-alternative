// Usage: npm run make-admin -- someone@example.com [admin|editor|user]
import { closeDb, cols, ROLES, type Role } from '../db.js';

const [email, role = 'admin'] = process.argv.slice(2);
if (!email || !ROLES.includes(role as Role)) {
  console.error('Usage: npm run make-admin -- <email> [admin|editor|user]');
  process.exit(1);
}
const { users } = await cols();
const r = await users.updateOne({ email: email.trim().toLowerCase() }, { $set: { role: role as Role, updatedAt: new Date() } });
console.log(r.matchedCount ? `${email} is now ${role}.` : `No account for ${email}. Register in the app first.`);
await closeDb();
process.exit(r.matchedCount ? 0 : 1);
