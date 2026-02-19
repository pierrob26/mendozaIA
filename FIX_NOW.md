# IMMEDIATE FIX FOR 500 ERROR

Run this ONE command to fix everything:

```bash
docker compose down && mvn clean package -DskipTests && docker compose up --build -d && sleep 20 && docker compose logs --tail=30 app
```

Or run the script:

```bash
chmod +x quick_fix.sh && ./quick_fix.sh
```

## What This Does:

1. **Stops containers** - Shuts down old code
2. **Cleans build** - Removes stale compiled classes
3. **Rebuilds app** - Compiles with RegistrationController disabled
4. **Restarts containers** - Starts with fresh code
5. **Shows logs** - Displays any errors

## Why You're Getting 500 Error:

The Docker container is running OLD compiled code that still has the **duplicate controller conflict**:
- `RegisterController` mapping to `/register` ✅ (good)
- `RegistrationController` mapping to `/register` ❌ (conflicts)

I disabled `RegistrationController` by commenting out `@Controller`, but Docker needs to rebuild to pick up the change.

## After Running the Fix:

Wait 20-30 seconds, then visit: http://localhost:8080/login

If you still see errors, check logs:
```bash
docker compose logs --tail=50 app
```

Look for:
- ✅ "Started FantasyIaApplication" = SUCCESS
- ❌ "Ambiguous mapping" = Still has old code (try again)
- ❌ "Column does not exist" = Need database migration

## If You Still Have Issues:

1. **Check if database is running:**
   ```bash
   docker compose ps
   ```

2. **Try full cleanup:**
   ```bash
   docker compose down
   docker system prune -f
   mvn clean
   rm -rf target/
   mvn package
   docker compose up --build -d
   ```

3. **Check database columns exist:**
   ```bash
   ./access_db.sh
   \d auction_items
   ```

---

**The fix is ready - just run the command above!**
