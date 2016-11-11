@echo off
pushd %~dp0
git add .
set /p message="Message du commit: "
git commit -m "%message%"
git pull
git push
echo.   
echo.   
echo.   
echo                        _. - ~ ~ ~ - .
echo     ..       __.    .-~               ~-.
echo     ((\     /   `}.~                     `.
echo      \\\   {     }               /     \   \         --------------------
echo  (\   \\~~       }                     }   \         FIN DE LA SAUVEGARDE
echo   \`.-~ -@~     }  ,-,.                )    \        --------------------
echo   (___     ) _}  (    :            / /      `.
echo    `----._-~.     _\ \ _       \   / /- _      `.
echo           ~~----~~  \ \ ~~--~~~(  + /     ~-.     ~- _
echo                     /  /         \  \          ~- . _ _~_-_.
echo                  __/  /          _\  )
echo                .k___.'         .k___/
echo.   
echo.   
pause
