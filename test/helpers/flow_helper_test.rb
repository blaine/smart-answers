require "test_helper"

class FlowHelperTest < ActionView::TestCase
  context "#forwarding_responses" do
    setup do
      stubs(:response_store).returns(
        ResponseStore.new(responses: { question1: "response1" }),
      )
    end

    should "return an empty hash for session based flows" do
      flow_object = SmartAnswer::Flow.new { response_store :session }
      stubs(:flow).returns(flow_object)

      assert_equal({}, forwarding_responses)
    end

    should "return all the previous responses for query parameter based flows" do
      flow_object = SmartAnswer::Flow.new { response_store :query_parameters }
      stubs(:flow).returns(flow_object)

      assert_equal({ question1: "response1" }, forwarding_responses)
    end
  end

  context "#presenter" do
    should "return the flow presenter" do
      params[:node_slug] = "question-2"

      flow_object = SmartAnswer::Flow.new { response_store :other }
      stubs(:flow).returns(flow_object)

      stubs(:response_store).returns(
        ResponseStore.new(responses: { question1: "response1" }),
      )

      assert_instance_of(FlowPresenter, presenter)
      assert_same flow_object, presenter.flow
    end
  end

  context "#flow" do
    should "return the flow for the current request" do
      params[:id] = "flow-name"

      flow_object = SmartAnswer::Flow.new { name "flow-name" }

      flow_registry = mock
      SmartAnswer::FlowRegistry.stubs(:instance).returns(flow_registry)
      flow_registry.expects(:find).with("flow-name").returns(flow_object)

      assert_same flow_object, flow
    end
  end

  context "#response_store" do
    context "for session based flow" do
      should "return a session response store with flow name and session" do
        params[:id] = "flow-name"

        store = mock

        flow_object = SmartAnswer::Flow.new { response_store :session }
        stubs(:flow).returns(flow_object)

        SessionResponseStore.expects(:new).with(
          flow_name: params[:id], session: session,
        ).returns(store)

        assert_same store, response_store
      end
    end

    context "for non-session based flow" do
      should "return a response store" do
        store = mock
        stubs(:request).returns(stub(query_parameters: {
          "question1": "response1",
          "key": "value",
        }))

        flow_object = SmartAnswer::Flow.new do
          response_store :other
          radio :question1
        end

        stubs(:flow).returns(flow_object)

        ResponseStore.expects(:new).with(
          responses: { "question1": "response1" },
        ).returns(store)

        assert_same store, response_store
      end
    end
  end

  context "#content_item" do
    should "return a content item for the flow" do
      flow_object = SmartAnswer::Flow.new { name "flow-name" }
      stubs(:flow).returns(flow_object)

      content_item_object = { "content_item": "value" }
      ContentItemRetriever.expects(:fetch).with("flow-name")
        .returns(content_item_object)

      assert_same content_item_object, content_item
    end
  end
end
