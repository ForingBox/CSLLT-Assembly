.model small
.stack 100h
.data
    inventory db "ID  Name      Quantity", 0Dh, 0Ah
    item1 db "1   ItemA     10", 0Dh, 0Ah
    item2 db "2   ItemB      2", 0Dh, 0Ah
    low_stock_alert db "LOW STOCK ALERT!", 0Dh, 0Ah, "$"
    prompt_order db "Please reorder item: ", "$"
    item_name db "ItemB", "$"

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Display inventory
    lea dx, inventory
    mov ah, 09h
    int 21h
    
    lea dx, item1
    mov ah, 09h
    int 21h
    
    lea dx, item2
    mov ah, 09h
    int 21h
    
    ; Check if item2 quantity is less than 3
    mov al, 2 ; quantity of item2
    cmp al, 3
    jge no_reorder
    
    ; Alert low stock and prompt reorder
    lea dx, low_stock_alert
    mov ah, 09h
    int 21h
    
    lea dx, prompt_order
    mov ah, 09h
    int 21h
    
    lea dx, item_name
    mov ah, 09h
    int 21h
    
no_reorder:
    ; End program
    mov ax, 4C00h
    int 21h
main endp
end main
