MuteIt for mac
===========================

Make macbook muted when headphone unplugged, just like user experience of iPhone.

## Why
When use iPhone, if you unplug headphone, the sound played will be muted automatically, I think this is a good user experience, but on mac, when you do the same thing, the sound will be still playing, and it embarrassed me a few times during my job.   

I do not know why Apple does not provide the same user experience between the two productions. Maybe in the future will. But now I just make a simple app to implement the same effect as iPhone.

## Demo
It is hard to use picture to demonstrate  the sound muted effect. So just use to log message to show how it works.   

It just does two things:  
1. detect headphone **unplugged** and do **mute** action  
2. detect headphone **plugged** and do **unmute** action  
![alt text][demo]

[demo]: 
https://raw.githubusercontent.com/hanks/MuteIt_for_mac/master/MuteIt/demo/demo.gif "demo"

## Install
Download app from <a href="https://github.com/hanks/MuteIt_for_mac/blob/master/MuteIt/Installer/MuteIt_Installer.dmg">here</a>, and install like other mac apps.

The installer UI will be like this(**please ignore the self-made slogan^_^**):    
![alt text][installer]  

[installer]: 
https://raw.githubusercontent.com/hanks/MuteIt_for_mac/master/MuteIt/demo/installer.png "installer"

##Usage
[status_bar]: 
https://raw.githubusercontent.com/hanks/MuteIt_for_mac/master/MuteIt/demo/system_menu.jpg "status_bar"

[run_on_startup]: 
https://raw.githubusercontent.com/hanks/MuteIt_for_mac/master/MuteIt/demo/run_on_startup.jpg "run_on_startup"

**MuteIt** is just a status bar app, just a icon in the system menu bar. 

Like below:  
![alt text][status_bar]  

And if you check **Run on startup** option, it will be added to the login item list like this:  
![alt text][run_on_startup] 

##Implementation
<ol>
  <li>CoreAudio API</li>
    <ol>
      <li>detect defaut output device</li> 
      <li>register callback function in the change event of output device, like plug and unplug headphone</li> 
      <li>implement mute and unmute action in the callback function, here I just use a simple one-line actionscript to do mute action.</li> 
    </ol>
  <li>Status bar application    
    <ol>
      It means the app has no window, no menu and just a icon in the system menu bar. Many app work like this. Like Alfred, popclip and etc. If your app function is very simple and a few menus can meet your needs. Status bar applcation is a good style you can try.
    </ol>
  </li>                
</ol>



## Bugs
1. when you first run MuteIt with no headphone, the sound will be muted.  
2. when you unplug headphone, there will be a very short time that sound will still be playing and then be muted.

## Contribution
**Waiting for your pull request**

## Lisence
MIT Lisence
