module FlowHelper
  def forwarding_responses
    flow.response_store == :query_parameters ? response_store.all : {}
  end

  def presenter
    @presenter ||= begin
      params.merge!(responses: response_store.all, node_name: node_name)
      FlowPresenter.new(params, flow)
    end
  end

  def flow
    @flow ||= SmartAnswer::FlowRegistry.instance.find(params[:id])
  end

  def response_store
    @response_store ||= if flow.response_store == :session
                          SessionResponseStore.new(flow_name: params[:id], session: session)
                        else
                          allowable_keys = flow.nodes.map(&:name)
                          query_parameters = request.query_parameters.slice(*allowable_keys)
                          ResponseStore.new(responses: query_parameters)
                        end
  end

  def content_item
    @content_item ||= ContentItemRetriever.fetch(flow.name)
  end

private

  def node_name
    @node_name ||= params[:node_slug].underscore if params[:node_slug].present?
  end

  def next_node_slug
    presenter.current_state.current_node.to_s.dasherize
  end
end
