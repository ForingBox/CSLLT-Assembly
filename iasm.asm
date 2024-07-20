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

    ; clear screen message
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
    ShowMessage mainMenu       ; Display main menu
    ShowMessage choiceInput    ; Prompt user for input
    GetInput                   ; Get user input
    
    cmp al, '1'                ; Check if input is '1'
    je MenuClear4Order         ; Jump to create order menu if '1'
    
    cmp al, '2'                ; Check if input is '2'
    je jmpInventory2           ; Jump to inventory menu if '2'

    cmp al, '3'                ; Check if input is '3'
    je exitProgram             ; Exit program if '3'

    jmp jmperrormenu           ; Jump to error handling if input is invalid

jmperrormenu:
    clearScreen                ; Clear screen
    ShowMessage invalidInput   ; Show invalid input message
    jmp menu                   ; Jump back to main menu

MenuClear4Order:
    clearScreen                ; Clear screen
    jmp createOrder            ; Jump to create order menu

exitProgram:
    mov ah, 4Ch                ; Terminate program
    int 21h

jmpInventory2:
    jmp checkInventory         ; Jump to check inventory

jmpmenu:
    jmp menu                   ; Jump back to main menu

jmperrororder:
    clearScreen                ; Clear screen
    ShowMessage invalidItemInput ; Show invalid item input message
    jmp createOrder            ; Jump back to create order menu

createOrder:
    ShowMessage orderList      ; Display order list
    call displayItem           ; Call procedure to display items
    ShowMessage orderMenu      ; Display order menu
    ShowMessage orderMsg       ; Prompt user to select item
    GetInput                   ; Get user input

    cmp al, '1'                ; Check if input is '1'
    je orderItem1              ; Jump to order item 1 if '1'

    cmp al, '2'                ; Check if input is '2'
    je orderItem2              ; Jump to order item 2 if '2'

    cmp al, '3'                ; Check if input is '3'
    je orderItem3              ; Jump to order item 3 if '3'

    cmp al, '4'                ; Check if input is '4'
    je jmpitem4                ; Jump to order item 4 if '4'

    cmp al, '5'                ; Check if input is '5'
    je jmpitem5                ; Jump to order item 5 if '5'

    cmp al, '6'                ; Check if input is '6'
    clearScreen                ; Clear screen
    je jmpmenu                 ; Jump back to main menu if '6'

    jmp jmperrororder          ; Jump to error handling if input is invalid

jmpInventory:
    jmp checkInventory         ; Jump to check inventory

orderItem1:
    orderStock itemN1Stock     ; Order stock for item 1
    jmp salemade               ; Jump to sale made

orderItem2:
    orderStock itemN2Stock     ; Order stock for item 2
    jmp salemade               ; Jump to sale made

jmpitem4:
    jmp orderItem4             ; Jump to order item 4

jmpitem5:
    jmp orderItem5             ; Jump to order item 5

salemade:
    clearScreen                ; Clear screen
    ShowMessage orderCreatedMsg ; Show order created message
    jmp createOrder            ; Jump back to create order menu

orderItem3:
    orderStock itemN3Stock     ; Order stock for item 3
    jmp salemade               ; Jump to sale made

orderItem4:
    orderStock itemN4Stock     ; Order stock for item 4
    jmp salemade               ; Jump to sale made

orderItem5:
    orderStock itemN5Stock     ; Order stock for item 5
    jmp salemade               ; Jump to sale made

outOfStock:
    cmp al, 0                  ; Check if stock is zero
    je OrderOutOfStock         ; Jump to out of stock if zero
    jmp createOrder            ; Jump back to create order menu

OrderOutOfStock:
    clearScreen                ; Clear screen
    ShowMessage noStockOrderMsg ; Show no stock order message
    jmp createOrder            ; Jump back to create order menu

jmpInmenu2:
    jmp menu                   ; Jump back to main menu

checkInventory:
    clearScreen                ; Clear screen
    ShowMessage inventoryList  ; Display inventory list
    call displayItem           ; Call procedure to display items
    ShowMessage inventoryMenu  ; Display inventory menu
    ShowMessage choiceInput    ; Prompt user for input
    GetInput                   ; Get user input
    
    cmp al, '1'                ; Check if input is '1'
    je incMenuClear            ; Jump to increase stock menu if '1'
    
    cmp al, '2'                ; Check if input is '2'
    je jmpInDecMenu2           ; Jump to decrease stock menu if '2'

    cmp al, '3'                ; Check if input is '3'
    clearScreen                ; Clear screen
    je jmpInmenu2              ; Jump back to main menu if '3'
    
    ShowMessage invalidInput   ; Show invalid input message
    jmp checkInventory         ; Jump back to check inventory

incMenuClear:
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump to increase stock menu

jmperrorInc:
    clearScreen                ; Clear screen
    ShowMessage invalidItemInput ; Show invalid item input message
    jmp incStockMenu           ; Jump back to increase stock menu

jmpInventory3:
    jmp checkInventory         ; Jump to check inventory

jmpInDecMenu2:
    clearScreen                ; Clear screen
    jmp jmpInDecMenu           ; Jump to decrease stock menu

incStockMenu:
    ShowMessage inventoryList  ; Display inventory list
    call displayItem           ; Call procedure to display items
    ShowMessage addStockmsg    ; Display add stock message
    GetInput                   ; Get user input

    cmp al, '1'                ; Check if input is '1'
    je addItem1                ; Jump to add item 1 if '1'

    cmp al, '2'                ; Check if input is '2'
    je addItem2                ; Jump to add item 2 if '2'

    cmp al, '3'                ; Check if input is '3'
    je addItem3                ; Jump to add item 3 if '3'

    cmp al, '4'                ; Check if input is '4'
    je jmpItemInc4             ; Jump to add item 4 if '4'

    cmp al, '5'                ; Check if input is '5'
    je jmpItemInc5             ; Jump to add item 5 if '5'

    cmp al, '6'                ; Check if input is '6'
    je jmpInventory3           ; Jump back to check inventory if '6'

    jmp jmperrorInc            ; Jump to error handling if input is invalid

jmpInDecMenu:
    jmp decStockMenu           ; Jump to decrease stock menu

addItem1:
    increStock itemN1Stock     ; Increase stock for item 1
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump back to increase stock menu

addItem2:
    increStock itemN2Stock     ; Increase stock for item 2
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump back to increase stock menu

jmpItemInc4:
    jmp addItem4               ; Jump to add item 4

jmpItemInc5:
    jmp addItem5               ; Jump to add item 5

addItem3:
    increStock itemN3Stock     ; Increase stock for item 3
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump back to increase stock menu

fullStock:
    clearScreen                ; Clear screen
    ShowMessage fullStockMsg   ; Show full stock message
    jmp incStockMenu           ; Jump back to increase stock menu

addItem4:
    increStock itemN4Stock     ; Increase stock for item 4
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump back to increase stock menu

addItem5:
    increStock itemN5Stock     ; Increase stock for item 5
    clearScreen                ; Clear screen
    jmp incStockMenu           ; Jump back to increase stock menu

jmpErrorDec:
    clearScreen                ; Clear screen
    ShowMessage invalidItemInput ; Show invalid item input message
    jmp decStockMenu           ; Jump back to decrease stock menu

jmpInmenu:
    jmp checkInventory         ; Jump back to check inventory

decStockMenu:
    ShowMessage inventoryList  ; Display inventory list
    call displayItem           ; Call procedure to display items
    ShowMessage decStockmsg    ; Display decrease stock message
    GetInput                   ; Get user input

    cmp al, '1'                ; Check if input is '1'
    je reduceItem1             ; Jump to reduce item 1 if '1'

    cmp al, '2'                ; Check if input is '2'
    je reduceItem2             ; Jump to reduce item 2 if '2'

    cmp al, '3'                ; Check if input is '3'
    je reduceItem3             ; Jump to reduce item 3 if '3'

    cmp al, '4'                ; Check if input is '4'
    je jmpItemDec4             ; Jump to reduce item 4 if '4'

    cmp al, '5'                ; Check if input is '5'
    je jmpItemDec5             ; Jump to reduce item 5 if '5'

    cmp al, '6'                ; Check if input is '6'
    je jmpInmenu               ; Jump back to check inventory if '6'

    jmp jmpErrorDec            ; Jump to error handling if input is invalid

reduceItem1:
    decStock itemN1Stock       ; Decrease stock for item 1
    clearScreen                ; Clear screen
    jmp decStockMenu           ; Jump back to decrease stock menu

reduceItem2:
    decStock itemN2Stock       ; Decrease stock for item 2
    clearScreen                ; Clear screen
    jmp decStockMenu           ; Jump back to decrease stock menu

jmpItemDec4:
    jmp reduceItem4            ; Jump to reduce item 4

jmpItemDec5:
    jmp reduceItem5            ; Jump to reduce item 5

reduceItem3:
    decStock itemN3Stock       ; Decrease stock for item 3
    clearScreen                ; Clear screen
    jmp decStockMenu           ; Jump back to decrease stock menu

noStock:
    clearScreen                ; Clear screen
    ShowMessage noStockDecMsg  ; Show no stock decrease message
    jmp decStockMenu           ; Jump back to decrease stock menu

reduceItem4:
    decStock itemN4Stock       ; Decrease stock for item 4
    clearScreen                ; Clear screen
    jmp decStockMenu           ; Jump back to decrease stock menu

reduceItem5:
    decStock itemN5Stock       ; Decrease stock for item 5
    clearScreen                ; Clear screen
    jmp decStockMenu           ; Jump back to decrease stock menu

closeProgram:
    mov ah, 4Ch                ; Terminate program
    int 21h
MAIN ENDP

displayItem PROC
    mov ax, @data
    mov ds, ax

    ; Display Item 1
    ShowMessage itemNum1       ; Show item 1
    cmp itemN1Stock, 3         ; Check if stock is 3 or less
    jle blinkItem1             ; Jump to blink item if stock is low
    ShowDigit itemN1Stock      ; Show stock digit
    jmp nextItem1              ; Jump to next item

blinkItem1:
    blink itemN1Stock          ; Blink item stock
    ShowMessage lowStockMsg1   ; Show low stock message
    jmp nextItem1              ; Jump to next item
    
nextItem1:
    ; Display Item 2
    ShowMessage itemNum2       ; Show item 2
    cmp itemN2Stock, 3         ; Check if stock is 3 or less
    jle blinkItem2             ; Jump to blink item if stock is low
    ShowDigit itemN2Stock      ; Show stock digit
    jmp nextItem2              ; Jump to next item

blinkItem2:
    blink itemN2Stock          ; Blink item stock
    ShowMessage lowStockMsg2   ; Show low stock message
    jmp nextItem2              ; Jump to next item

nextItem2:
    ; Display Item 3
    ShowMessage itemNum3       ; Show item 3
    cmp itemN3Stock, 3         ; Check if stock is 3 or less
    jle blinkItem3             ; Jump to blink item if stock is low
    ShowDigit itemN3Stock      ; Show stock digit
    jmp nextItem3              ; Jump to next item

blinkItem3:
    blink itemN3Stock          ; Blink item stock
    ShowMessage lowStockMsg3   ; Show low stock message
    jmp nextItem3              ; Jump to next item

nextItem3:
    ; Display Item 4
    ShowMessage itemNum4       ; Show item 4
    cmp itemN4Stock, 3         ; Check if stock is 3 or less
    jle blinkItem4             ; Jump to blink item if stock is low
    ShowDigit itemN4Stock      ; Show stock digit
    jmp nextItem4              ; Jump to next item

blinkItem4:
    blink itemN4Stock          ; Blink item stock
    ShowMessage lowStockMsg4   ; Show low stock message
    jmp nextItem4              ; Jump to next item
nextItem4:

    ; Display Item 5
    ShowMessage itemNum5       ; Show item 5
    cmp itemN5Stock, 3         ; Check if stock is 3 or less
    jle blinkItem5             ; Jump to blink item if stock is low
    ShowDigit itemN5Stock      ; Show stock digit
    jmp nextItem5              ; Jump to next item

blinkItem5:
    blink itemN5Stock          ; Blink item stock
    ShowMessage lowStockMsg5   ; Show low stock message
    jmp nextItem5              ; Jump to next item
nextItem5:

    ret
displayItem ENDP
END MAIN
