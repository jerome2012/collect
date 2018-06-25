defmodule Collect.API.Ptes.V1.Params do
  use Maru.Helper

  params :common_params do
    requires(:id, type: String)
    # requires(:stat, type: String)
    requires(:ptif, type: String)
    requires(:ts, type: String)
  end
end

defmodule Maru.Types.Stat do
  use Maru.Type

  def parse(input, _), do: input |> :cow_qs.urlencode()
end

# alias Maru.Resource

defmodule Collect.API.Ptes.V1 do
  use Maru.Router
  helpers(Collect.API.Ptes.V1.Params)
  # import Plug.Conn

  ########################################################
  # prefix(:datacenter)

  # params in route
  # route_param :sid, type: String do
  #   params do
  #     use :datacenter_params
  #     optional(:pid, type: String)
  #   end
  ########################################################
  #### 第一版
  # params do
  #   requires(:id, type: String)
  #   requires(:stat, type: String)
  #   requires(:p, type: String)
  #   requires(:tl, type: String)
  #   requires(:ptif, type: String)
  #   requires(:ts, type: String)
  #   requires(:ref, type: String, default: "")
  #   # optional(:ref, type: String)
  # end

  ########################################################
  ## pn
  params do
    use :common_params
    requires(:p, type: String)
    requires(:tl, type: String)
    requires(:stat, type: String)
    requires(:ref, type: String, default: "")
  end

  get "pn" do
    case params[:id] do
      nil -> IO.inspect("id is nil")
      id -> IO.inspect(id, label: "id is : ")
    end

    ua = Plug.Conn.get_req_header(conn, "user-agent")
    realip = Plug.Conn.get_req_header(conn, "x-real-ip")
    forwardedfor = Plug.Conn.get_req_header(conn, "x-forwarded-for")

    peerip = conn.port

    IO.inspect(ua, label: "ua =")
    IO.inspect(realip, label: "realip =")
    IO.inspect(forwardedfor, label: "forwardedfor =")
    IO.inspect(peerip, label: "peer =")

    IO.inspect(params, label: "params =")

    IO.inspect(conn, label: "conn =")

    json(conn, params)
  end

  ## pv
  params do
    use :datacenter_params
    requires(:stat, type: String)
  end

  get "pv" do
    json(conn, params)
  end

  params do
    use :common_params
    requires(:stat, type: Stat)
  end

  get "oc" do
    case params[:stat] do
      nil -> IO.inspect("oc stat is nil")
      stat -> IO.inspect(stat, label: "oc stat is")
    end

    stat1 = conn.private.maru_params.stat

    IO.inspect(conn, label: "conn =")

    IO.inspect(stat1, label: "stat1 =")
    json(conn, params)
  end

  # params do
  # end

  get "help" do
    put_resp_content_type(conn, "html/text")
    text(conn, "success")
  end
end

defmodule Collect.API.Ptes do
  use Maru.Router

  plug(
    Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]
  )

  mount(Collect.API.Ptes.V1)

  rescue_from [Maru.Exceptions.InvalidFormat, Maru.Exceptions.Validation], as: e do
    IO.inspect(e)

    conn
    |> put_status(:bad_request)
    |> text("bad request #{inspect(e)}")
  end

  rescue_from Maru.Exceptions.NotFound do
    conn
    |> put_status(404)
    |> text("Not Found")
  end

  rescue_from :all, as: e do
    IO.inspect(e, label: "--->")

    conn
    |> put_status(500)
    |> text("Server Error")
  end
end
