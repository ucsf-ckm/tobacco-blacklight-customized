require "spec_helper"

describe Search do
  it "has an optional numfound field" do
    search = Search.create()
    chelimsky = User.create!(first_name: "David", last_name: "Chelimsky")

    expect(User.ordered_by_last_name).to eq([chelimsky, lindeman])
  end
end