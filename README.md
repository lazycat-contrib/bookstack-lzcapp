# BookStack (LazyCat LPK)

Wiki-style documentation platform with books, chapters and pages.

- Upstream: https://github.com/BookStackApp/BookStack
- Image: `linuxserver/bookstack:26.09.2` (mirror mode, digest-matched)
- License: MIT (full text in `content/licenses/LICENSE`)
- Containers: app + MariaDB 10.11

## Notes

- Upstream ships no official image; `linuxserver/bookstack` is used.
- LinuxServer's s6 init already waits for the DB, runs `artisan migrate --force`
  and fixes ownership. It does **not** create an admin user.
- `content/create-admin.sh` is mounted into `/custom-cont-init.d/` and runs once:
  it counts users and calls `bookstack:create-admin --initial` only when the table
  is empty. Email and password come from deploy params, so there is no built-in credential.
- `APP_KEY` comes from a platform stable secret.
- No mail service configured (invites / password reset by email unavailable).
- Not yet verified on a real device.
