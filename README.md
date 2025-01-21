# ZenVPN Authorization Provider for Apache2

## Dependencies
- `lua-json`
- `lua-sec`
- `lua-socket`

```bash
apt install lua-json lua-sec lua-socket
```

## Peer dependencies
- `apache2`

## Setup

1. Enable `mod_lua`:

```bash
a2enmod lua
service restart apache2
```

2. Create configuration:

```bash
cp zenvpn-authz.conf /etc/apache2/conf-enabled/
```

3. Add the following configuration to virtual host for location `/admin`:

```conf
<Location /admin>
  <RequireAny>
    Require ip 127 # Allow from local ip
    Require ip ::1 # Allow from local ip
    Require zenvpn c6a25ea4-beff-4aea-8931-6ed6d99c74e8 # Allow from ZenVPN
  </RequireAny>
</Location>
```

4. Reload apache:

```bash
service reload apache2
```

## Cache

To use cache add `LuaScope` directive to virtual host:

```conf
LuaScope server
```
