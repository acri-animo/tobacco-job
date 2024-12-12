# FiveM Tobacco Job (Sandbox/Mythic Framework)

FiveM tobacco job for SandboxRP version of Mythic framework.

Note: Requires Sandbox version of Mythic framework & FiveDevs Daddy Tobbaco MLO


You can rename the files as you wish and place them within their respective directories within sandbox-labor (client/server/config).

You must also add the following to sandbox-labor > server > startup.lua (edit the pay & reputation as you wish).

```lua
Labor.Jobs:Register("Tobacco", "Tobacco", 0, 1500, 85)
```

Edit job rewards in server.lua