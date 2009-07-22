class HostsController < ApplicationController
  active_scaffold  :host do |config|
    config.list.columns = [:name, :operatingsystem, :architecture, :last_compile ]
    config.columns = %w{ name ip architecture media domain operatingsystem mac root_pass serial puppetmaster disk comment}
    config.columns[:architecture].form_ui  = :select
    config.columns[:media].form_ui  = :select
    config.columns[:domain].form_ui  = :select
    config.columns[:subnet].form_ui  = :select
    config.columns[:operatingsystem].form_ui  = :select
    columns[:architecture].label = "Arch"
  end

  def externalNodes
    if params.has_key? "fqdn"
      fqdn = params.delete "fqdn"
    else
      head(:bad_request) and return
    end
    host = Host.find_by_name fqdn.split(".")[0]
    param = {}
    param[:puppetmaster] = host.puppetmaster
    param[:longsitename] = host.domain.fullname
    param[:hostmode] = host.environment
    puppetclasses = []
    puppetclasses << "common"
    render :text => Hash['classes' => puppetclasses, 'parameters' => param].to_yaml and return
  end
end