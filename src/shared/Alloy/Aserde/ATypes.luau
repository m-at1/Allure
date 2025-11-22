--!strict

--stylua: ignore start

--[[type: SerDes]]
export type SerDes<T> = {
    Ser: (buff: buffer, index: number, val: T) -> number;
    Des: (buff: buffer, index: number, additional: any?) -> (T, number)
}

--[[type: Aserde]]
export type Aserde = {

}


return nil
--stylua: ignore end
