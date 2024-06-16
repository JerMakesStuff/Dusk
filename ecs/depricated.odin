/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package ecs

@(deprecated = "queryComponent is depricated, use query instead")
queryComponent :: proc(world: ^World, componentTypeId: typeid) -> []Entity {
	entities := make([dynamic]Entity, context.temp_allocator)
	componentData := world.componentStorage[componentTypeId]
	for entity in componentData.entities {
		append(&entities, entity)
	}
	return entities[:]
}

@(deprecated = "queryComponents is depricated, use query instead")
queryComponents :: proc(world: ^World, components: ..typeid) -> []Entity {
	entities := make([dynamic]Entity, context.temp_allocator)
	matchCounts: map[Entity]int

	compCounts := len(components)
	for componentTypeId in components {
		componentData := world.componentStorage[componentTypeId]
		for entity in componentData.entities {
			matchCounts[entity] += 1
		}
	}

	for entity, count in matchCounts {
		if count == compCounts do append(&entities, entity)
	}

	return entities[:]
}
