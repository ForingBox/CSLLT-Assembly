.model small
.stack 100h
.data

    lowStockMsg1 db 10, 13, '*** ALERT: Biscuit stock is low! ***', 10, 13, '$'
    lowStockMsg2 db 10, 13, '*** ALERT: Milk stock is low! ***', 10, 13, '$'
    lowStockMsg3 db 10, 13, '*** ALERT: Candy stock is low! ***', 10, 13, '$'
    lowStockMsg4 db 10, 13, '*** ALERT: Keyboard stock is low! ***', 10, 13, '$'


    itemNum1 db 10,13, '1. Biscuit              ', 9, '$', 10
    itemNum2 db 10,13, '2. Milk                 ' , 9, '$', 10
    itemNum3 db 10,13, '3. Candy                ', 9, '$', 10
    itemNum4 db 10,13, '4. Keyboard             ', 9, '$', 10

    itemN1Stock db 8     ; Stock for Biscuit
    itemN2Stock db 6     ; Stock for Milk
    itemN3Stock db 9     ; Stock for Candy    
    itemN4Stock db 3     ; Stock for keyboard

    mainMenu db 10,13, '=================================', 10,13
             db '   Inventory System Main Menu', 10,13
             db '=================================', 10,13
             db '1. Create Order',10,13
             db '2. Check Inventory',10,13
             db '3. Exit',10,13 
             db '=================================', 10,13, '$'

    inventoryList db 10,13, '====================================', 10,13
                 db '       Inventory Menu', 10,13
                 db '====================================', 10,13
                 db '   Item                     Quantity', 10,13, '$'


    inventoryMenu db 10,13, '====================================', 10,13
                 db '1. Replenish Stock', 10,13
                 db '2. Reduce Stock', 10,13
                 db '3. Back', 10,13 
                 db '====================================', 10,13,'$'

    orderList db 10,13, '====================================', 10,13
                 db '           Order Menu',10,13
                 db '====================================', 10,13
                 db '   Item                     Quantity', 10,13, '$'

    orderMenu db 10,13,'====================================', 10,13
                 db    'Select item (1-4)',10,13
                 db '5. Back',10,13, '$'
               

    addStockmsg db 10,13,'====================================', 10,13
                db 'Select the item you want to restock (1 - 4)',10,13
                db '5. Back',10,13,'$'
    
    decStockmsg db 10,13,'====================================', 10,13 
                db  'Select the item you want to reduce (1 - 4)',10,13
                db  '5. Back',10,13,'$'
    
    orderMsg db 10,13, 'Select the item you want place order (1 - 4)',10,13,'$'
    
    choiceInput db 10,13, 'Enter your choice (1 - 3): $'
    
    invalidInput db 10,13, 'Invalid Input, choose between 1 - 3',10,13,'$'

    noStockMsg db 10,13, 'Stock cannot be decreased. Item is out of stock.', 10,13, '$'

    fullStockMsg db 10,13, 'Stock cannot be increased. Item is in maximum stock.', 10,13, '$'

    noStockOrderMsg db 10,13, 'Stock cannot be order. Item is out of stock.', 10,13, '$'

    noStockDecMsg db 10,13, 'Stock cannot be decreased. Item is out of stock.', 10,13, '$'

    orderCreatedMsg db 10,13, 'WE RICH THE ORDER HAS BEEN MADE.', 10,13,'$'


ShowMessage Macro Mess
    mov ah, 09h
    mov dx, offset Mess
    int 21h
EndM

GetInput Macro get
    mov ah, 01h
    int 21h
EndM


decStock Macro val
	mov al,val
    cmp al, 0
    jle noStock
	dec al
	mov val, al
EndM

orderStock Macro val
    mov al,val
    cmp al, 0
    jle outOfStock
    dec al
    mov val, al
EndM

increStock Macro val
	mov al,val
    cmp al,99
    jge fullStock
	inc al
	mov val, al
EndM

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

blinkRedText Macro 
    mov ah, 09h
    mov bl, 04h
    or bl, 80h
    mov cx, 1
    int 100h

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
    je createOrder
    cmp al, '2'
    je jmpInventory
    cmp al, '3'
    jmp closeProgram
    
    ShowMessage invalidInput
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
    je orderItem4

    cmp al, '5'
    je menu

    ShowMessage invalidInput
    jmp createOrder

jmpInventory:
    jmp checkInventory

orderItem1:
    orderStock itemN1Stock
    ShowMessage orderCreatedMsg
    jmp createOrder

orderItem2:
    orderStock itemN2Stock
    ShowMessage orderCreatedMsg
    jmp createOrder

orderItem3:
    orderStock itemN3Stock
    ShowMessage orderCreatedMsg
    jmp createOrder

orderItem4:
    orderStock itemN4Stock
    ShowMessage orderCreatedMsg
    jmp createOrder

outOfStock:
    cmp al, 0
    je OrderOutOfStock
    cmp al, 3
    jle OrderLowStock
    jmp createOrder

OrderOutOfStock:
    ShowMessage noStockDecMsg
    jmp createOrder

OrderLowStock:
    ShowMessage noStockMsg
    jmp createOrder
    
jmpInmenu2:
    jmp menu

checkInventory:
    ShowMessage inventoryList
    call displayItem
    ShowMessage inventoryMenu
    ShowMessage choiceInput
    GetInput
    
    cmp al, '1'
    je incStockMenu
    
    cmp al, '2'
    je jmpInDecMenu

    cmp al, '3'
    je jmpInmenu2
    
    ShowMessage invalidInput
    jmp checkInventory
    

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
    je addItem4    

    cmp al, '5'
    je checkInventory

    ShowMessage invalidInput
    jmp incStockMenu

jmpInDecMenu:
    jmp decStockMenu

addItem1:
    increStock itemN1Stock
    jmp incStockMenu

addItem2:
    increStock itemN2Stock
    jmp incStockMenu

addItem3:
    increStock itemN3Stock
    jmp incStockMenu

addItem4:
    increStock itemN4Stock
    jmp incStockMenu

fullStock:
    ShowMessage fullStockMsg
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
    je reduceItem4

    cmp al, '5'
    je jmpInmenu

    ShowMessage invalidInput
    jmp decStockMenu

reduceItem1:
    decStock itemN1Stock
    jmp decStockMenu

reduceItem2:
    decStock itemN2Stock
    jmp decStockMenu

reduceItem3:
    decStock itemN3Stock
    jmp decStockMenu

reduceItem4:
    decStock itemN4Stock
    jmp decStockMenu

noStock:
    cmp al, 0
    je DecOutOfStock
    cmp al, 3
    jle DecLowStock
    jmp decStockMenu

DecOutOfStock:
    ShowMessage noStockDecMsg
    jmp decStockMenu

DecLowStock:
    ShowMessage noStockMsg
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
    ShowDigit itemN1Stock
    cmp itemN1Stock, 3
    jg nextItem1
    ShowMessage lowStockMsg1
nextItem1:

    ; Display Item 2
    ShowMessage itemNum2
    ShowDigit itemN2Stock
    cmp itemN2Stock, 3
    jg nextItem2
    ShowMessage lowStockMsg2
nextItem2:

    ; Display Item 3
    ShowMessage itemNum3
    ShowDigit itemN3Stock
    cmp itemN3Stock, 3
    jg nextItem3
    ShowMessage lowStockMsg3
nextItem3:

    ; Display Item 4
    ShowMessage itemNum4
    ShowDigit itemN4Stock
    cmp itemN4Stock, 3
    jg nextItem4
    ShowMessage lowStockMsg4
nextItem4:

    ret
displayItem ENDP
END MAIN
