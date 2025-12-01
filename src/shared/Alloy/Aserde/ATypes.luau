--!strict

--stylua: ignore start

--[[type: SerDes]]
export type SerDes<T=any> = {
    Ser: (buff: buffer, index: number, val: T, ...any?) -> (buffer);
    Des: (buff: buffer, index: number, ...any?) -> (T, number)
}

--[[type: Aserde]]
export type Aserde = {

}


return nil
--stylua: ignore end
