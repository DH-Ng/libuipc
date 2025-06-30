#include <affine_body/abd_time_integrator.h>
#include <time_integrator/bdf1_flag.h>
#include <kernel_cout.h>
#include <muda/ext/eigen/log_proxy.h>

namespace uipc::backend::cuda
{
class ABDBDF1Integrator final : public ABDTimeIntegrator
{
  public:
    using ABDTimeIntegrator::ABDTimeIntegrator;

    void do_build(BuildInfo& info) override
    {
        // require the BDF1 flag
        require<BDF1Flag>();
    }

    virtual void do_init(InitInfo& info) override {}

    virtual void do_predict_dof(PredictDofInfo& info) override
    {
        using namespace muda;
        ParallelFor()
            .file_line(__FILE__, __LINE__)
            .apply(info.qs().size(),
                   [is_fixed   = info.is_fixed().cviewer().name("is_fixed"),
                    is_dynamic = info.is_dynamic().cviewer().name("is_dynamic"),
                    q_prevs    = info.q_prevs().cviewer().name("q_prev"),
                    q_vs       = info.q_vs().cviewer().name("q_velocities"),
                    q_tildes   = info.q_tildes().viewer().name("q_tilde"),
                    affine_gravity = info.gravities().cviewer().name("affine_gravity"),
                    dt   = info.dt(),
                    cout = KernelCout::viewer()] __device__(int i) mutable
                   {
                       auto& q_prev = q_prevs(i);
                       auto& q_v    = q_vs(i);
                       auto& g      = affine_gravity(i);

                       // 0) fixed: q_tilde = q_prev;
                       Vector12 q_tilde = q_prev;

                       if(!is_fixed(i))
                       {
                           // 1) static problem: q_tilde = q_prev + g * dt * dt;
                           q_tilde += g * dt * dt;

                           // 2) dynamic problem q_tilde = q_prev + q_v * dt + g * dt * dt;
                           if(is_dynamic(i))
                           {
                               q_tilde += q_v * dt;
                           }
                       }

                       q_tildes(i) = q_tilde;
                   });
    }

    virtual void do_update_state(UpdateStateInfo& info) override
    {
        using namespace muda;
        ParallelFor()
            .file_line(__FILE__, __LINE__)
            .apply(info.qs().size(),
                   [qs      = info.qs().cviewer().name("qs"),
                    q_vs    = info.q_vs().viewer().name("q_vs"),
                    q_prevs = info.q_prevs().viewer().name("q_prevs"),
                    dt      = info.dt()] __device__(int i) mutable
                   {
                       auto& q_v    = q_vs(i);
                       auto& q_prev = q_prevs(i);

                       const auto& q = qs(i);

                       q_v = (q - q_prev) * (1.0 / dt);

                       q_prev = q;
                   })
            .wait();
    }
};

REGISTER_SIM_SYSTEM(ABDBDF1Integrator);
}  // namespace uipc::backend::cuda