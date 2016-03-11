%% Display message
% Made by Taisei

function displaymessage(textmessage)
 
    cgmakesprite(100,1000,50,0,0,0)
    cgsetsprite(100)
    cgpencol(1,1,1)
    cgfont('Arial',40)
    cgtext(textmessage,0,0)
    cgsetsprite(0)
    cgrotatesprite(100,0,-350,-1000,50,0)

end