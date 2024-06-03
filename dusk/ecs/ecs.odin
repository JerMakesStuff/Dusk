/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package ecs

import "core:mem"
import "core:log"

Entity :: distinct i32
World :: struct {
    compStorage:map[typeid]mem.Raw_Dynamic_Array,
    freeCompIds:map[typeid][dynamic]int,
    entStorage:[dynamic]Entity,
    freeEntIds:[dynamic]Entity,
    entityComponentLookup:map[typeid]map[Entity]int,
}

createEntity :: proc(world:^World) -> Entity {
    if len(world.freeEntIds) != 0 {
        ent:Entity = pop(&world.freeEntIds)
        world.entStorage[int(ent)] = ent
        return ent
    }
    ent:Entity = Entity(len(world.entStorage))
    append(&world.entStorage, ent)
    return ent
}

deleteEntity :: proc(world:^World, ent:Entity) {
    append(&world.freeEntIds, ent)
    world.entStorage[int(ent)] = Entity(-1)
    for t, &lookup in world.entityComponentLookup {
        _, ok := lookup[ent]
        if ok {
            removeComponentWithTypeId(world, ent, t)
        }
    }
}

isEntityValid :: proc(world:^World, ent:Entity) -> bool {
    return world.entStorage[int(ent)] == ent
}

addComponent :: proc(world:^World, ent:Entity, comp:$T) {
    tid := typeid_of(T)
    _, ok := world.compStorage[tid]
    if !ok {
        tStorage := make([dynamic]T)
        world.compStorage[tid] = transmute(mem.Raw_Dynamic_Array)tStorage
    }
    compId:int = -1
    storage := transmute(^[dynamic]T)&world.compStorage[tid]
    if len(world.freeCompIds[tid]) != 0 {
        compId = pop(&world.freeCompIds[tid])
        storage[compId] = comp
    } else {
        compId = len(storage)
        append(storage, comp)
    }
    lookup, ok1 := &world.entityComponentLookup[tid]
    if !ok1 {
        world.entityComponentLookup[tid] = make(map[Entity]int)
        lookup = &world.entityComponentLookup[tid]
    } 
    lookup[ent] = compId
}

removeComponent :: proc(world:^World, ent:Entity, comp:$T) {
    tid := typeid_of(T)
    removeComponentWithTypeId(world, ent, tid)
}

removeComponentWithTypeId :: proc(world:^World, ent:Entity, tid:typeid) {
    lookup , ok1 := &world.entityComponentLookup[tid]
    if !ok1 {
        log.warn("Failed to find lookup for comp type:", tid)
        return
    }
    compId, ok2 := lookup[ent]
    if !ok2 {
        log.warn("Failed to find comp index of type", tid, "for Entity", ent)
        return
    }
    append(&world.freeCompIds[tid], compId)
    delete_key(lookup, ent)
    log.debug("Removed Component of type",tid,"from Entity:",ent)
}

queryComponent :: proc(world:^World, $T:typeid) -> []Entity {
    tid := typeid_of(T)
    entities := make([dynamic]Entity, context.temp_allocator)
    ents := &world.entityComponentLookup[tid]
    for ent in ents {
        append(&entities, ent)
    }
    return entities[:]
}

queryComponents :: proc(world:^World, comps: ..typeid) -> []Entity {
    entities := make([dynamic]Entity, context.temp_allocator)
    matchCounts:map[Entity]int

    compCounts := len(comps)
    for comp in comps {
        ents := &world.entityComponentLookup[comp]
        for ent in ents {
            _, hasEnt := matchCounts[ent]
            if !hasEnt do matchCounts[ent] = 1
            else do matchCounts[ent] += 1
        }
    }

    for ent, count in matchCounts {
        if count == compCounts do append(&entities, ent)
    }

    return entities[:]
}

getComponent :: proc(world: ^World, ent:Entity, $T:typeid) -> ^T {
    tid := typeid_of(T)
    _, ok := world.compStorage[tid]
    if !ok do log.panic("[DUSK][ECS] Attepted get get component of type", tid)

    lookup, lookupOK := &world.entityComponentLookup[tid]
    if !lookupOK do log.panic("[DUSK][ECS] entity",ent,"has no component of type", tid)
    compid, compOk := lookup[ent]
    if !compOk do log.panic("[DUSK][ECS] entity",ent,"has no component of type", tid)
    
    storage := transmute(^[dynamic]T)&world.compStorage[tid]
    retVal:^T = &storage[compid]
    return retVal
}