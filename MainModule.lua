                                                                                                                                                    --[[
   
    Name: Exo's Discord API
    Author: Exo_Byte
    Version: 1.2.5
   
    Important Information
     - It is recommended that you require this module via it's asset id.
       This is because I am constantly updating it and adding new features.
     - Http being enabled is REQUIRED to use this module.
       If you don't know that, then you probably don't know how to use this module, and should stay away from it.
     - The proxy in the settings should redirect all calls to api.discordapp.com.
     - Do not tamper with the main code unless you know what you are doing.
   
    API Documentation:
    ** This module will be referred to as "discordService"  (in a required format) throughout the documentation **
   
    Functions:
        discordService:GetWebhook(url)          -- Returns a Webhook object.
        discordService:SetCustomProxy(url)      -- Changes the proxy used by the module.
        discordService:CheckApiStatus()         -- Returns a bool on wether or not Discord's API is operational or not.
   
    Events:
        StatusChanged                           -- Fires with the old status and the new status, and can be connected to a function using ":Connect"
   
    Objects:
     - Webhook:
        Properties:
            Name                                -- The name of the webhook.
            GuildId                             -- The Guild Id of the Guild/Server the webhook is in.
            ChannelId                           -- The Channel Id the webhook is in.
            Creator                             -- The Id of the user who created the webhook.
            Avatar                              -- The avatar URL of the webhook.
            Token                               -- The token of the webhook.
        Functions:
            webhook:Post({
                Content = message,              -- The message the webhook should post.
                Username = customUsername,      -- A custom username for the webhook to have. [optional]
                AvatarURL = customAvatarUrl,    -- A custom avatar for the webhook to have. [optional]
                Tts = false,                    -- Wether or not the message is text to speech. [optional]
                File = ""                       -- any file attachments that the webhook should add to the message. [optional]
                Embeds = tableOfImbeds          -- A table of embeds. [optional]
                PayloadJSON                     -- Any additional payloads in JSON format. [optional]
            })
       
    MAIN CODE:
                                                                                                                                                    --]]
 
local proxy = "https://discord.osyr.is"
local httpService = game:GetService("HttpService")
local status = "operational"
local statusChanged = Instance.new("BindableEvent")
 
local discordService = { }
discordService.__index = discordService
local self = discordService
discordService.StatusChanged = statusChanged
 
function discordService:CheckHttp()
    local success,fail = pcall(function()
        httpService:GetAsync("http://www.google.com")
    end)
    if success and not fail then
        return true
    else
        return false
    end
end
 
 
function discordService:GetApiStatus(givenTimeZone)
    local statusData = httpService:JSONDecode(httpService:GetAsync("https://srhpyqt94yxb.statuspage.io/api/v2/summary.json"))
    if statusData.components[1].status == "operational" then
        return true
    else
        return false
    end
end
 
 
function discordService:SetCustomProxy(url)
    proxy = url
end
 
function discordService:GetWebhook(url)
    if self:GetApiStatus() ~= true then
        return error("Discord's API is offline")
    end
    url = string.gmatch(url, string.sub(url, 0, string.find(url,"m")+1), proxy)
    local webhookInfo = httpService:GetAsync(url)
    local webhook = { }
    webhook.Name = webhookInfo.name
    webhook.GuildId = webhookInfo.guild_id
    webhook.ChannelId = webhookInfo.channel_id
    webhook.Creator = webhookInfo.user
    webhook.Avatar = webhookInfo.avatar
    webhook.Token = webhookInfo.token
    function webhook:Post(data)
        local finalData = {}
        if data.Content then
            finalData["content"] = data.Content
        end
        if data.Username then
            finalData["username"] = data.Username
        end
        if data.AvatarURL then
            finalData["avatar_url"] = data.AvatarURL
        end
        if data.Tts then
            finalData["tts"] = data.Tts
        end
        if data.Embeds then
            finalData["embeds"] = data.Embeds
        end
        if data.PayloadJSON then
            finalData["payload_json"] = data.PayloadJSON
        end
        return httpService:PostAsync(url, httpService:JSONDecode(finalData))
    end
    function webhook
    return webhook
end
 
spawn(function()
    while wait(0.5) do
        local newStatus = self:GetApiStatus()
        if newStatus ~= status then
            statusChanged:Fire(status, newStatus)
            status = newStatus
        end
    end
end)
 
return discordService
