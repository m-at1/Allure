--!strict

--stylua: ignore start

--[[type: SerDes]]
export type SerDes<T=any> = {
    Ser: (buff: buffer, index: number, val: T, ...any?) -> (buffer, number);
    Des: (buff: buffer, index: number, ...any?) -> (T, number)
}

--[[type: Aserde]]
export type Aserde = {
    SpecialType: {},
    ReadBuffer: (buffer)->{ },
    CreateBuffer: ({ })->buffer
}


return nil
--stylua: ignore end
