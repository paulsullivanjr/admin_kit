defmodule AdminKit.Telemetry do
  @moduledoc """
  Telemetry events emitted by AdminKit.

  | Event | Measurements | Metadata |
  |-------|-------------|----------|
  | `[:admin_kit, :resource, :list, :start/stop]` | duration | resource, params |
  | `[:admin_kit, :resource, :create, :start/stop]` | duration | resource, attrs, result |
  | `[:admin_kit, :resource, :update, :start/stop]` | duration | resource, record, result |
  | `[:admin_kit, :resource, :delete, :start/stop]` | duration | resource, record, result |
  | `[:admin_kit, :action, :run, :start/stop]` | duration | action, record, result |
  """

  @doc "Wraps a function call with start/stop/exception telemetry events."
  def span(event_name, metadata, fun) do
    start_time = System.monotonic_time()

    :telemetry.execute(
      [:admin_kit | event_name] ++ [:start],
      %{system_time: System.system_time()},
      metadata
    )

    try do
      result = fun.()
      duration = System.monotonic_time() - start_time

      :telemetry.execute(
        [:admin_kit | event_name] ++ [:stop],
        %{duration: duration},
        Map.put(metadata, :result, result)
      )

      result
    rescue
      e ->
        duration = System.monotonic_time() - start_time

        :telemetry.execute(
          [:admin_kit | event_name] ++ [:exception],
          %{duration: duration},
          Map.merge(metadata, %{kind: :error, reason: e})
        )

        reraise e, __STACKTRACE__
    end
  end
end
