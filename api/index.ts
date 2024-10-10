import fastify from 'fastify'
import { KeyType, MessageType } from './schema/data_schema'

const server = fastify()

server.get('/ping', async (request, reply) => {
    return 'pong hello\n'
})

server.post<{ Body: KeyType }>('/key', async (request, reply) => {
    const { key } = request.body
    if (key == 'abc') {
        reply.status(200).send({ status: 1 });
    } else {
        reply.status(500).send({ status: 0 })
    }
})

server.post<{ Body: MessageType }>('/message-and-status', async (request, reply) => {
    try {
        const { message, date, type } = request.body
        if (type == 'status') {
            console.log('update status')
        } else {
            console.log('message ', message, 'date ', date)
        }
        reply.status(200).send({ status: 1 })
    } catch (e) {
        reply.status(500).send({ status: 0 })
    }
})


server.listen({ port: 8080, host: '0.0.0.0' }, (err, address) => {
    if (err) {
        console.error(err)
        process.exit(1)
    }
    console.log(`Server listening at ${address}`)
})