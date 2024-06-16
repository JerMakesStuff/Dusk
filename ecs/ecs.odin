/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package ecs

import "base:builtin"
import "core:log"
import "core:slice"

Entity :: distinct i32

EntityData :: struct {
	entity: Entity,
	components: map[typeid]int // The index into the Component storage for this entities components
}

ComponentData :: struct {
	type: typeid,
	entities: [dynamic]Entity, 
}

TypedComponentData :: struct($T:typeid) {
	using componentData:ComponentData,
	storage:[dynamic]T,
}

World :: struct {
	componentStorage:  map[typeid]^ComponentData,
	entityStorage:  [dynamic]EntityData,
	unusedEnityIds: [dynamic]Entity,

	queryHasTypeLookup: map[typeid]map[typeid]bool,
	queryNeedsRefreshed: map[typeid]bool,
}

createEntity :: proc(world: ^World) -> Entity {
	if(world.entityStorage == nil) {
		world.entityStorage = make([dynamic]EntityData)
		world.unusedEnityIds = make([dynamic]Entity)
		world.componentStorage = make(map[typeid]^ComponentData)
		world.queryHasTypeLookup = make(map[typeid]map[typeid]bool)
		world.queryNeedsRefreshed = make(map[typeid]bool)
	}
	if len(world.unusedEnityIds) != 0 {
		entity: Entity = pop(&world.unusedEnityIds)
		world.entityStorage[int(entity)].entity = entity
		return entity
	}

	entity := Entity(len(world.entityStorage))
	entityData := EntityData{}
	entityData.entity = entity
	entityData.components = make(map[typeid]int)
	append(&world.entityStorage, entityData )
	log.debug("[DUSK][ECS] Created Entity", entityData.entity)
	return entityData.entity
}

deleteEntity :: proc(world: ^World, entity: Entity) {
	append(&world.unusedEnityIds, entity)
	entityData := &world.entityStorage[int(entity)]
	for component in entityData.components {
		removeComponentWithTypeId(world, entity, component)
	}
	clear(&entityData.components)
	entityData.entity = Entity(-1)
}

isEntityValid :: #force_inline proc(world: ^World, ent: Entity) -> bool {
	return world.entityStorage[int(ent)].entity == ent
}

addComponent :: proc(world: ^World, entity: Entity, component: $T) {
	componentData := transmute(^TypedComponentData(T))world.componentStorage[typeid_of(T)]
	
	if componentData == nil {
		componentData = new(TypedComponentData(T))
		componentData.type = T
		componentData.entities = make([dynamic]Entity)
		componentData.storage = make([dynamic]T)
		world.componentStorage[typeid_of(T)] = componentData
		log.debug("[DUSK][ECS] Creating storage for Components of type", typeid_of(T))
	}

	componentId := 0 if componentData.storage == nil else len(componentData.storage)
	append(&componentData.storage, component)

	entityData := &world.entityStorage[entity]
	entityData.components[typeid_of(T)] = componentId
	append(&componentData.entities, entity)
	
	setQueriesWithComponentOfTypeIdToRefresh(world, T)
	
	log.debug("[DUSK][ECS] Components of type", typeid_of(T), "to Entity", entity)
}

removeComponent :: proc(world: ^World, ent: Entity, comp: $T) {
	removeComponentWithTypeId(world, ent, typeid_of(T))
}

removeComponentWithTypeId :: proc(world: ^World, entity: Entity, componentTypeId: typeid) {
	entityData := world.entityStorage[entity]
	delete_key(&entityData.components, componentTypeId)

	componentData := world.componentStorage[componentTypeId]
	entityIndex, found := slice.linear_search(componentData.entities[:], entity)
	if found do ordered_remove(&componentData.entities, entityIndex)
	
	world.entityStorage[entity] = entityData
	world.componentStorage[componentTypeId] = componentData
	setQueriesWithComponentOfTypeIdToRefresh(world, componentTypeId)
	log.debug("[DUSK][ECS] Removed Component of type", componentTypeId, "from Entity:", entity)
}

getComponent :: proc(world: ^World, entity: Entity, $T: typeid) -> ^T {
	componentData := transmute(^TypedComponentData(T))world.componentStorage[typeid_of(T)]
	if componentData == nil {
		log.warn("[DUSK][ECS] No storage for component type", typeid_of(T))
		return nil
	}
	entityData := world.entityStorage[entity]
	componentId, compIDOk := entityData.components[typeid_of(T)]
	if !compIDOk {
		log.debug("[DUSK][ECS] Entity", entity, "has no component of type", typeid_of(T))
		return nil
	}
	retVal: ^T = &componentData.storage[componentId]
	return retVal
}

cleanup :: proc(world:^World) {
	for &entity in world.entityStorage {
		delete(entity.components)
	}
	for _, &componentData in world.componentStorage {
		delete(componentData.entities)
	}
	delete(world.componentStorage)
	delete(world.entityStorage)
	delete(world.unusedEnityIds)
	delete(world.queryHasTypeLookup)
	delete(world.queryNeedsRefreshed)
}