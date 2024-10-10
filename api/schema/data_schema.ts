import { Static, Type } from '@sinclair/typebox'

export const KeyType = Type.Object({
    key: Type.String(),
})

export const MessageType = Type.Object({
    message: Type.String(),
    date: Type.String(),
    type: Type.String()
})

export type MessageType = Static<typeof MessageType>
export type KeyType = Static<typeof KeyType>