.model small
.stack 100h
.data
    ; Messages to display when stock is low
    lowStockMsg1 db 10, 13, '*** ALERT: Biscuit stock is low! ***',  '$'
    lowStockMsg2 db 10, 13, '*** ALERT: Milk stock is low! ***',  '$'
    lowStockMsg3 db 10, 13, '*** ALERT: Candy stock is low! ***',  '$'
    lowStockMsg4 db 10, 13, '*** ALERT: Keyboard stock is low! ***',  '$'
    lowStockMsg5 db 10, 13, '*** ALERT: Microphone stock is low! ***', '$'

    ; Item descriptions
    itemNum1 db 10,13, '1. Biscuit              ', 9, '$', 10
    itemNum2 db 10,13, '2. Milk                 ' , 9, '$', 10
    itemNum3 db 10,13, '3. Candy                ', 9, '$', 10
    itemNum4 db 10,13, '4. Keyboard             ', 9, '$', 10
    itemNum5 db 10,13, '5. Microphone           ', 9, '$', 10

    ; Initial stock values
    itemN1Stock db 8     ; Stock for Biscuit
    itemN2Stock db 6     ; Stock for Milk
    itemN3Stock db 9     ; Stock for Candy    
    itemN4Stock db 3     ; Stock for Keyboard
    itemN5Stock db 3     ; Stock for Microphone

    ; Main menu message
    mainMenu db 10,13, '=======================================', 10,13
             db '      Inventory System Main Menu', 10,13
             db '=======================================', 10,13
             db '1. Create Order',10,13
             db '2. Check Inventory',10,13
             db '3. Exit',10,13 
             db '=======================================', 10,13, '$'

    ; Inventory list header
    inventoryList db 10,13, '=======================================', 10,13
                 db '           Inventory Menu', 10,13
                 db '=======================================', 10,13
                 db '   Item                     Quantity', 10,13, '$'

    ; Inventory menu options
    inventoryMenu db 10,13, '=======================================', 10,13
                 db '1. Replenish Stock', 10,13
                 db '2. Reduce Stock', 10,13
                 db '3. Back', 10,13 
                 db '=======================================', 10,13,'$'

    ; Order list header
    orderList db 10,13, '=======================================', 10,13
                 db '               Order Menu',10,13
                 db '=======================================', 10,13
                 db '   Item                     Quantity', 10,13, '$'

    ; Order menu options
    orderMenu db 10,13,'=======================================', 10,13
                 db 'Select item (1-5)',10,13
                 db '6. Back',10,13, '$'

    ; Restock menu message
    addStockmsg db 10,13,'=======================================', 10,13
                db 'Select the item you want to restock (1 - 5)',10,13
                db '6. Back',10,13,'$'
    
    ; Reduce stock menu message
    decStockmsg db 10,13,'=======================================', 10,13 
                db 'Select the item you want to reduce (1 - 5)',10,13
                db '6. Back',10,13,'$'
    
    ; Order prompt message
    orderMsg db 10,13, 'Select the item you want place order (1 - 5)',10,13,'$'
    
    ; Input prompt
    choiceInput db 10,13, 'Enter your choice (1 - 3): $'
    
    ; Invalid input message
    invalidInput db 10,13, 'Invalid Input, choose between 1 - 3',10,13,'$'

    ; Invalid input message for items
    invalidItemInput db 10,13, 'Invalid Input, choose between 1 - 6',10,13,'$'

    ; Full stock message
    fullStockMsg db 10,13, 'Stock cannot be increased. Item is in maximum stock.', 10,13, '$'

    ; No stock order message
    noStockOrderMsg db 10,13, 'Stock cannot be order. Item is out of stock.', 10,13, '$'

    ; No stock decrease message
    noStockDecMsg db 10,13, 'Stock cannot be decreased. Item is out of stock.', 10,13, '$'

    ; Order created message
    orderCreatedMsg db 10,13, 'WE RICH THE ORDER HAS BEEN MADE.', 10,13,'$'


    clearScreenMsg db 10,13, ' ', 10,13
                    db ' ' ,10,13
                    db ' ' ,10,13
                    db ' ' ,10,13, '$'

; Macro to scroll the screen up by a specified number of lines
clearScreen Macro Mess
ShowMessage clearScreenMsg
ShowMessage clearScreenMsg
ShowMessage clearScreenMsg
ShowMessage clearScreenMsg

EndM

; Macro to display a message
ShowMessage Macro Mess
    mov ah, 09h
    mov dx, offset Mess
    int 21h
EndM

; Macro to get input from user
GetInput Macro get
    mov ah, 01h
    int 21h
EndM

; Macro to decrease stock
decStock Macro val
    mov al,val
    cmp al, 0
    jle noStock
    dec al
    mov val, al
EndM

; Macro to order stock
orderStock Macro val
    mov al,val
    cmp al, 0
    jle outOfStock
    dec al
    mov val, al
EndM

; Macro to increase stock
increStock Macro val
    mov al,val
    cmp al,99
    jge fullStock
    inc al
    mov val, al
EndM

; Macro to display a digit
ShowDigit Macro db 
    mov al,db
    mov bl,0
    add al,bl
    
    aam
    add ax,3030h
    
    mov dh,al
    mov dl,ah
    
    mov ah,2
    int 21h
    
    mov dl,dh
    mov ah,2
    int 21h
EndM

; Macro to blink a digit
blink MACRO db
    mov ah, 09h    ; 09h to print string
    mov bl, 04h    ; 04h for color attribute
    or bl, 80h     ; set bl bit 7 to 1 (blink attribute)
    mov cx, 2      ; set cx to 2 (number of characters to print)
    int 10h        ; interrupt 10h (video services)

    mov al, db     ; get value from variable db

    aam            ; ASCII adjust ax after multiply
    add ax, 3030h  ; convert al to ASCII

    mov bl, 04h    ; set color to red

    ; Split db into two registers
    mov dh, al     ; dh --> carries lower nibble of AX(tens digit)
    mov dl, ah     ; dl --> carries upper nibble of AX(units digit)

    mov ah, 2      ; 2 to print character
    int 21h        
    mov dl, dh     ; move dh(lower digit) back to dl
    int 21h        
EndM

.code
MAIN PROC
    mov ax, @data
    mov ds, ax
    
menu:
    ShowMessage mainMenu
    ShowMessage choiceInput
    GetInput
    
    cmp al, '1'
    je MenuClear4Order
    
    cmp al, '2'
    je jmpInventory2

    cmp al, '3'
    je exitProgram

    jmp jmperrormenu

jmperrormenu:
    clearScreen
    ShowMessage invalidInput
    jmp menu

MenuClear4Order:
    clearScreen
    jmp createOrder

exitProgram:
    mov ah, 4Ch
    int 21h

jmpInventory2:
    jmp checkInventory

jmpmenu:
    jmp menu

createOrder:
    ShowMessage orderList
    call displayItem
    ShowMessage orderMenu
    ShowMessage orderMsg
    GetInput

    cmp al, '1'
    je orderItem1

    cmp al, '2'
    je orderItem2

    cmp al, '3'
    je orderItem3

    cmp al, '4'
    je jmpitem4

    cmp al, '5'
    je jmpitem5

    cmp al, '6'
    clearScreen
    je jmpmenu

    ShowMessage invalidItemInput
    jmp createOrder

jmpInventory:
    jmp checkInventory

orderItem1:
    orderStock itemN1Stock
    jmp salemade

orderItem2:
    orderStock itemN2Stock
    jmp salemade

jmpitem4:
    jmp orderItem4

jmpitem5:
    jmp orderItem5

salemade:
    clearScreen
    ShowMessage orderCreatedMsg
    jmp createOrder

orderItem3:
    orderStock itemN3Stock
    jmp salemade

orderItem4:
    orderStock itemN4Stock
    jmp salemade


orderItem5:
    orderStock itemN5Stock
    jmp salemade


outOfStock:
    cmp al, 0
    je OrderOutOfStock
    jmp createOrder

OrderOutOfStock:
    clearScreen
    ShowMessage noStockOrderMsg
    jmp createOrder

jmpInmenu2:
    jmp menu

checkInventory:
    clearScreen
    ShowMessage inventoryList
    call displayItem
    ShowMessage inventoryMenu
    ShowMessage choiceInput
    GetInput
    
    cmp al, '1'
    je incMenuClear
    
    cmp al, '2'
    je jmpInDecMenu2

    cmp al, '3'
    clearScreen
    je jmpInmenu2
    
    ShowMessage invalidInput
    jmp checkInventory

jmpInventory3:
    jmp checkInventory

incMenuClear:
    clearScreen
    jmp incStockMenu

jmpInDecMenu2:
    clearScreen
    jmp jmpInDecMenu

incStockMenu:
    ShowMessage inventoryList
    call displayItem
    ShowMessage addStockmsg
    GetInput

    cmp al, '1'
    je addItem1

    cmp al, '2'
    je addItem2

    cmp al, '3'
    je addItem3

    cmp al, '4'
    je jmpItemInc4    

    cmp al, '5'
    je jmpItemInc5

    cmp al, '6'
    je jmpInventory3

    ShowMessage invalidItemInput
    jmp incStockMenu

jmpInDecMenu:
    jmp decStockMenu

addItem1:
    increStock itemN1Stock
    clearScreen
    jmp incStockMenu

addItem2:
    increStock itemN2Stock
    clearScreen
    jmp incStockMenu

jmpItemInc4:
    jmp addItem4

jmpItemInc5:
    jmp addItem5

addItem3:
    increStock itemN3Stock
    jmp incStockMenu

fullStock:
    clearScreen
    ShowMessage fullStockMsg
    jmp incStockMenu

addItem4:
    increStock itemN4Stock
    clearScreen
    jmp incStockMenu

addItem5:
    increStock itemN5Stock
    clearScreen
    jmp incStockMenu

jmpInmenu:
    jmp checkInventory

decStockMenu:
    ShowMessage inventoryList
    call displayItem
    ShowMessage decStockmsg
    GetInput

    cmp al, '1'
    je reduceItem1

    cmp al, '2'
    je reduceItem2

    cmp al, '3'
    je reduceItem3

    cmp al, '4'
    je jmpItemDec4

    cmp al, '5'
    je jmpItemDec5

    cmp al, '6'
    je jmpInmenu

    ShowMessage invalidItemInput
    jmp decStockMenu

reduceItem1:
    decStock itemN1Stock
    clearScreen
    jmp decStockMenu

reduceItem2:
    decStock itemN2Stock
    clearScreen
    jmp decStockMenu

jmpItemDec4:
    jmp reduceItem4

jmpItemDec5:
    jmp reduceItem5

reduceItem3:
    decStock itemN3Stock
    clearScreen
    jmp decStockMenu

noStock:
    clearScreen
    ShowMessage noStockDecMsg
    jmp decStockMenu

reduceItem4:
    decStock itemN4Stock
    clearScreen
    jmp decStockMenu

reduceItem5:
    decStock itemN5Stock
    clearScreen
    jmp decStockMenu

closeProgram:
    mov ah, 4Ch
    int 21h
MAIN ENDP

displayItem PROC
    mov ax, @data
    mov ds, ax

    ; Display Item 1
    ShowMessage itemNum1
    cmp itemN1Stock, 3    
    jle blinkItem1
    ShowDigit itemN1Stock
    jmp nextItem1

blinkItem1:
    blink itemN1Stock
    ShowMessage lowStockMsg1
    jmp nextItem1
    
nextItem1:
    ; Display Item 2
    ShowMessage itemNum2
    cmp itemN2Stock, 3    
    jle blinkItem2
    ShowDigit itemN2Stock
    jmp nextItem2

blinkItem2:
    blink itemN2Stock
    ShowMessage lowStockMsg2
    jmp nextItem2

nextItem2:
    ; Display Item 3
    ShowMessage itemNum3
    cmp itemN3Stock, 3    
    jle blinkItem3
    ShowDigit itemN3Stock
    jmp nextItem3

blinkItem3:
    blink itemN3Stock
    ShowMessage lowStockMsg3
    jmp nextItem3

nextItem3:
    ; Display Item 4
    ShowMessage itemNum4
    cmp itemN4Stock, 3    
    jle blinkItem4
    ShowDigit itemN4Stock
    jmp nextItem4

blinkItem4:
    blink itemN4Stock
    ShowMessage lowStockMsg4
    jmp nextItem4
nextItem4:

    ; Display Item 5
    ShowMessage itemNum5
    cmp itemN5Stock, 3    
    jle blinkItem5
    ShowDigit itemN5Stock
    jmp nextItem5

blinkItem5:
    blink itemN5Stock
    ShowMessage lowStockMsg5
    jmp nextItem5
nextItem5:

    ret
displayItem ENDP
END MAIN
