extrn C Matrix_New              :far
extrn C Matrix_GetRangeCount    :far
extrn C Matrix_GetColumnsCount  :far
extrn C Matrix_GetElement       :far
extrn C Matrix_SetElement       :far

matrix struc global method{
        New :DWORD              = Matrix_New
        GetRangeCount :DWORD    = Matrix_GetRangeCount
        GetColumnsCount :DWORD  = Matrix_GetColumnsCount
        GetElement :DWORD       = Matrix_GetElement
        SetElement :DWORD       = Matrix_SetElement
    }
    FullLink label DWORD
    dw 0
    Segm dw ?
ends