---
sidebar_position: 3
---

# 📘Introduction

This library is composed by 5 different files.

![](https://cdn.discordapp.com/attachments/670023265455964198/979065288932872233/unknown.png)

The only file you need to require at any point is the main ProNet file which can be called from both the client and the server.

Depending on the waypoint from which you require the file it will provide you with different options. This API will provide you detailed information about both ends (The Server and the Client).

```luau
local ProNet = require(ReplicatedStorage.ProNet) --Change to whatever directory you have your ProNet in (recommended: ReplicatedStorage)
```