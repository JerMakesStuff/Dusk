package ecs

QueryResult :: struct($T1:typeid) {
    entity:Entity,
    value1:^T1
}

QueryResult2 :: struct($T1:typeid, $T2:typeid) {
    using _ : QueryResult(T1),
    value2:^T2
}

QueryResult3 :: struct($T1:typeid, $T2:typeid, $T3:typeid) {
    using _ : QueryResult2(T1, T2),
    value3:^T3
}

QueryResult4 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid) {
    using _ : QueryResult3(T1, T2, T3),
    value4:^T4
}

QueryResult5 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid) {
    using _ : QueryResult4(T1, T2, T3, T4),
    value5:^T5
}

QueryResult6 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid) {
    using _ : QueryResult5(T1, T2, T3, T4, T5),
    value6:^T6
}

QueryResult7 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid) {
    using _ : QueryResult6(T1, T2, T3, T4, T5, T6),
    value7:^T7
}

QueryResult8 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid) {
    using _ : QueryResult7(T1, T2, T3, T4, T5, T6, T7),
    value8:^T8
}

QueryResult9 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid) {
    using _ : QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8),
    value9:^T9
}

QueryResult10 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid, $T10:typeid) {
    using _ : QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9),
    value10:^T10
}

query_1 :: proc(world:^World, $T1:typeid) -> []QueryResult(T1) {
    @(static) entities : [dynamic]QueryResult(T1)

    if !(QueryResult(T1) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult(T1)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult(T1)]
        queryTypeLookup[T1] = true
    }

    if !(QueryResult(T1) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult(T1)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult(T1)]) {
        clear(&entities)
        componentData := world.componentStorage[T1]
        if(componentData == nil) do return entities[:]    
        for entity in componentData.entities {
            result:QueryResult(T1)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, T1)
            append(&entities, result)
        }
        world.queryNeedsRefreshed[QueryResult(T1)] = false
    }

    return entities[:]
}

query_2 :: proc(world:^World, $T1:typeid, $T2:typeid) -> []QueryResult2(T1, T2) {
    @(static) entities : [dynamic]QueryResult2(T1, T2)

    if !(QueryResult2(T1, T2) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult2(T1, T2)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult2(T1, T2)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
    }

    if !(QueryResult2(T1, T2) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult2(T1, T2)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult2(T1, T2)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 2 {
                result:QueryResult2(T1, T2)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                append(&entities, result)
            }
        }
    }
    return entities[:]
}


query_3 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid) -> []QueryResult3(T1, T2, T3) {
    @(static) entities : [dynamic]QueryResult3(T1, T2, T3)

    if !(QueryResult3(T1, T2, T3) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult3(T1, T2, T3)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult3(T1, T2, T3)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
    }

    if !(QueryResult3(T1, T2, T3) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult3(T1, T2, T3)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult3(T1, T2, T3)]) {
        clear(&entities)
    
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 3 {
                result:QueryResult3(T1, T2, T3)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                append(&entities, result)
            }
        }
    }
    return entities[:]
}

query_4 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid) -> []QueryResult4(T1, T2, T3, T4) {
    @(static) entities : [dynamic]QueryResult4(T1, T2, T3, T4)

    if !(QueryResult4(T1, T2, T3, T4) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult4(T1, T2, T3, T4)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult4(T1, T2, T3, T4)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
    }

    if !(QueryResult4(T1, T2, T3, T4) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult4(T1, T2, T3, T4)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult4(T1, T2, T3, T4)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 4 {
                result:QueryResult4(T1, T2, T3, T4)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}


query_5 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid) -> []QueryResult5(T1, T2, T3, T4, T5) {
    @(static) entities : [dynamic]QueryResult5(T1, T2, T3, T4, T5)

    if !(QueryResult5(T1, T2, T3, T4, T5) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult5(T1, T2, T3, T4, T5)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult5(T1, T2, T3, T4, T5)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
    }

    if !(QueryResult5(T1, T2, T3, T4, T5) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult5(T1, T2, T3, T4, T5)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult5(T1, T2, T3, T4, T5)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 5 {
                result:QueryResult5(T1, T2, T3, T4, T5)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                result.value5 = _query_get_component_from_lookup(world, entity, T5)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query_6 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid) -> []QueryResult6(T1, T2, T3, T4, T5, T6) {
    @(static) entities : [dynamic]QueryResult6(T1, T2, T3, T4, T5, T6)
    
    if !(QueryResult6(T1, T2, T3, T4, T5, T6) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult6(T1, T2, T3, T4, T5, T6)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult6(T1, T2, T3, T4, T5, T6)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
        queryTypeLookup[T6] = true
    }

    if !(QueryResult6(T1, T2, T3, T4, T5, T6) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult6(T1, T2, T3, T4, T5, T6)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult6(T1, T2, T3, T4, T5, T6)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T6) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 6 {
                result:QueryResult6(T1, T2, T3, T4, T5, T6)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                result.value5 = _query_get_component_from_lookup(world, entity, T5)
                result.value6 = _query_get_component_from_lookup(world, entity, T6)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query_7 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid) -> []QueryResult7(T1, T2, T3, T4, T5, T6, T7) {
    @(static) entities := make([dynamic]QueryResult7(T1, T2, T3, T4, T5, T6, T7), 0, 10000, context.temp_allocator)
    
    if !(QueryResult7(T1, T2, T3, T4, T5, T6, T7) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult7(T1, T2, T3, T4, T5, T6, T7)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult7(T1, T2, T3, T4, T5, T6, T7)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
        queryTypeLookup[T6] = true
        queryTypeLookup[T7] = true
    }

    if !(QueryResult7(T1, T2, T3, T4, T5, T6, T7) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult7(T1, T2, T3, T4, T5, T6, T7)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult7(T1, T2, T3, T4, T5, T6, T7)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T6) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T7) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 7 {
                result:QueryResult7(T1, T2, T3, T4, T5, T6, T7)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                result.value5 = _query_get_component_from_lookup(world, entity, T5)
                result.value6 = _query_get_component_from_lookup(world, entity, T6)
                result.value7 = _query_get_component_from_lookup(world, entity, T7)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query_8 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid) -> []QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8) {
    @static entities := [dynamic]QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)
    
    if !(QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
        queryTypeLookup[T6] = true
        queryTypeLookup[T7] = true
        queryTypeLookup[T8] = true
    }

    if !(QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T6) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T7) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T8) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 8 {
                result:QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                result.value5 = _query_get_component_from_lookup(world, entity, T5)
                result.value6 = _query_get_component_from_lookup(world, entity, T6)
                result.value7 = _query_get_component_from_lookup(world, entity, T7)
                result.value8 = _query_get_component_from_lookup(world, entity, T8)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query_9 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid) -> []QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    @(static) entities := [dynamic]QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)
    
    if !(QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
        queryTypeLookup[T6] = true
        queryTypeLookup[T7] = true
        queryTypeLookup[T8] = true
        queryTypeLookup[T9] = true
    }

    if !(QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T6) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T7) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T8) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T9) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 8 {
                result:QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)
                result.entity = entity
                result.value1 = _query_get_component_from_lookup(world, entity, T1)
                result.value2 = _query_get_component_from_lookup(world, entity, T2)
                result.value3 = _query_get_component_from_lookup(world, entity, T3)
                result.value4 = _query_get_component_from_lookup(world, entity, T4)
                result.value5 = _query_get_component_from_lookup(world, entity, T5)
                result.value6 = _query_get_component_from_lookup(world, entity, T6)
                result.value7 = _query_get_component_from_lookup(world, entity, T7)
                result.value8 = _query_get_component_from_lookup(world, entity, T8)
                result.value9 = _query_get_component_from_lookup(world, entity, T9)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query_10 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid, $T10:typeid) -> []QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    @(static) entities : [dynamic]QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)
    
    if !(QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) in world.queryHasTypeLookup) {
        world.queryHasTypeLookup[QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)] = make(map[typeid]bool)
        queryTypeLookup := &world.queryHasTypeLookup[QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)]
        queryTypeLookup[T1] = true
        queryTypeLookup[T2] = true
        queryTypeLookup[T3] = true
        queryTypeLookup[T4] = true
        queryTypeLookup[T5] = true
        queryTypeLookup[T6] = true
        queryTypeLookup[T7] = true
        queryTypeLookup[T8] = true
        queryTypeLookup[T9] = true
        queryTypeLookup[T10] = true
    }

    if !(QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) in world.queryNeedsRefreshed) {
        world.queryNeedsRefreshed[QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)] = true
    }

    if(world.queryNeedsRefreshed[QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)]) {
        clear(&entities)
        matchCounts: map[Entity]int = make(map[Entity]int, 0, context.temp_allocator)

        if _query_lookup_count_for_type(world, &matchCounts, T1 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T2 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T3 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T4 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T5 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T6 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T7 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T8 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T9 ) == 0 do return entities[:]
        if _query_lookup_count_for_type(world, &matchCounts, T10) == 0 do return entities[:]
        
        for entity, count in matchCounts {
            if count == 10 {
                result:QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)
                result.entity  = entity
                result.value1  = _query_get_component_from_lookup(world, entity, T1)
                result.value2  = _query_get_component_from_lookup(world, entity, T2)
                result.value3  = _query_get_component_from_lookup(world, entity, T3)
                result.value4  = _query_get_component_from_lookup(world, entity, T4)
                result.value5  = _query_get_component_from_lookup(world, entity, T5)
                result.value6  = _query_get_component_from_lookup(world, entity, T6)
                result.value7  = _query_get_component_from_lookup(world, entity, T7)
                result.value8  = _query_get_component_from_lookup(world, entity, T8)
                result.value9  = _query_get_component_from_lookup(world, entity, T9)
                result.value10 = _query_get_component_from_lookup(world, entity, T10)
                append(&entities, result)
            }
        }
    }

    return entities[:]
}

query :: proc { query_1, query_2, query_3, query_4, query_5, query_6, query_7, query_8, query_9, query_10 }

setQueriesWithComponentOfTypeIdToRefresh :: proc(world:^World, componentTypeId:typeid) {
    for queryType, lookup in world.queryHasTypeLookup {
        if componentTypeId in lookup {
            world.queryNeedsRefreshed[queryType] = true
        }
    }
}

@(private="file")
_query_lookup_count_for_type :: proc(world:^World, matchCounts:^map[Entity]int, componentTypeId:typeid) -> int {
    componentData := world.componentStorage[componentTypeId]
    if(componentData == nil) do return 0
    for entity in componentData.entities {
        matchCounts[entity] += 1
    }
    return len(componentData.entities)
}

@(private="file")
_query_get_component_from_lookup :: proc(world:^World, entity:Entity, $T:typeid) -> ^T {
	componentData := transmute(^TypedComponentData(T))world.componentStorage[typeid_of(T)]
    entityData := world.entityStorage[entity]
    componentId := entityData.components[T]
    return &componentData.storage[componentId];
}
