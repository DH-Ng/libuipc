#include <uipc/core/i_engine.h>
#include <dylib.hpp>

namespace uipc::core
{
void IEngine::init(internal::World& w)
{
    do_init(w);
}

void IEngine::advance()
{
    do_advance();
}

void IEngine::backward()
{
    do_backward();
}

void IEngine::sync()
{
    do_sync();
}

void IEngine::retrieve()
{
    do_retrieve();
}

Json IEngine::to_json() const
{
    return do_to_json();
}

bool IEngine::dump()
{
    return do_dump();
}

bool IEngine::recover(SizeT dst_frame)
{
    return do_recover(dst_frame);
}

bool IEngine::write_vertex_pos_to_sim(span<const Vector3> positions, IndexT global_vertex_offset, IndexT local_vertex_offset, SizeT vertex_count, string system_name)
{
    return do_write_vertex_pos_to_sim(positions, global_vertex_offset, local_vertex_offset, vertex_count, system_name);
}


SizeT IEngine::frame() const
{
    return get_frame();
}

EngineStatusCollection& IEngine::status()
{
    return get_status();
}

const FeatureCollection& IEngine::features() const
{
    return get_features();
}

Json IEngine::do_to_json() const
{
    return Json{};
}

bool IEngine::do_dump()
{
    return true;
}

bool IEngine::do_recover(SizeT dst_frame)
{
    return true;
}

bool IEngine::do_write_vertex_pos_to_sim(span<const Vector3> positions, IndexT global_vertex_offset, IndexT local_vertex_offset, SizeT vertex_count, string system_name)
{
    return true;
}

}  // namespace uipc::core
