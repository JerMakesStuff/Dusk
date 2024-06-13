/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package ecs

import "base:builtin"
import "core:log"
import "core:mem"

Entity :: distinct i32
World :: struct {
	compStorage:           map[typeid]mem.Raw_Dynamic_Array,
	freeCompIds:           map[typeid][dynamic]int,
	entStorage:            [dynamic]Entity,
	freeEntIds:            [dynamic]Entity,
	entityComponentLookup: map[typeid]map[Entity]int,
}

createEntity :: proc(world: ^World) -> Entity {
	if len(world.freeEntIds) != 0 {
		ent: Entity = pop(&world.freeEntIds)
		world.entStorage[int(ent)] = ent
		return ent
	}
	ent: Entity = Entity(len(world.entStorage))
	append(&world.entStorage, ent)
	log.debug("[DUSK][ECS] Created Entity", ent)
	return ent
}

deleteEntity :: proc(world: ^World, ent: Entity) {
	append(&world.freeEntIds, ent)
	world.entStorage[int(ent)] = Entity(-1)
	for t in world.entityComponentLookup {
		removeComponentWithTypeId(world, ent, t)
	}
}

isEntityValid :: #force_inline proc(world: ^World, ent: Entity) -> bool {
	return world.entStorage[int(ent)] == ent
}

addComponent :: proc(world: ^World, ent: Entity, comp: $T) {
	tid := typeid_of(T)
	_, storageOk := world.compStorage[tid]
	if !storageOk {
		newStorage := make([dynamic]T, 0, 200000)
		world.compStorage[tid] = transmute(mem.Raw_Dynamic_Array)newStorage
		log.debug("[DUSK][ECS] Creating storage for Components of type", tid)
	}
	compID: int = -1
	storage := transmute(^[dynamic]T)&world.compStorage[tid]
	if len(world.freeCompIds[tid]) != 0 {
		compID = pop(&world.freeCompIds[tid])
		storage[compID] = comp
	} else {
		compID = len(storage)
		append(storage, comp)
	}
	lookup, lookupOK := &world.entityComponentLookup[tid]
	if !lookupOK {
		world.entityComponentLookup[tid] = make(map[Entity]int)
		lookup = &world.entityComponentLookup[tid]
		log.debug("[DUSK][ECS] Creating lookup table for Components of type", tid)
	}
	lookup[ent] = compID
	log.debug("[DUSK][ECS] Components of type", tid, "to Entity", ent)

}

removeComponent :: proc(world: ^World, ent: Entity, comp: $T) {
	tid := typeid_of(T)
	removeComponentWithTypeId(world, ent, tid)
}

removeComponentWithTypeId :: proc(world: ^World, ent: Entity, tid: typeid) {
	lookup, lookupOK := &world.entityComponentLookup[tid]
	if !lookupOK {
		log.debug("[DUSK][ECS] No entities have component of type", tid)
		return
	}
	compID, compIDOk := lookup[ent]
	if !compIDOk {
		log.debug("[DUSK][ECS] Entity", ent, "has no component of type", tid)
		return
	}
	append(&world.freeCompIds[tid], compID)
	delete_key(lookup, ent)
	log.debug("[DUSK][ECS] Removed Component of type", tid, "from Entity:", ent)
}


getComponent :: proc(world: ^World, ent: Entity, $T: typeid) -> ^T {
	tid := typeid_of(T)
	_, storageOk := world.compStorage[tid]
	if !storageOk {
		log.warn("[DUSK][ECS] No storage for component type", tid)
		return nil
	}
	storage := transmute(^[dynamic]T)&world.compStorage[tid]

	lookup, lookupOK := &world.entityComponentLookup[tid]
	if !lookupOK {
		log.debug("[DUSK][ECS] No entities have component of type", tid)
		return nil
	}

	compID, compIDOk := lookup[ent]
	if !compIDOk {
		log.debug("[DUSK][ECS] Entity", ent, "has no component of type", tid)
		return nil
	}

	retVal: ^T = &storage[compID]
	return retVal
}
