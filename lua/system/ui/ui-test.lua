local text = access_system("ui.init").text
local win = access_system("ui.init").win

TestCtn = text("Resize to see its effect").padding({1, 2}).build()

PP = win.CreatePopup(TestCtn, {})
NewObj = text({"Resize to see effect"}).build()
PP2 =
    win.CreatePopup(
    NewObj,
    {
        position = {
            col = "50%",
            row = "5"
        }
    }
)

PP2.open()
PP.open()
