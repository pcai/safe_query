require "spec_helper"

RSpec.describe ActiveRecord::Relation::SafeQuery do
  it "raises an error when iterating over a relation without a limit" do
    expect { User.all.each {} }.to raise_error(ActiveRecord::UnsafeQueryError)
  end

  it "does not raise an error when iterating over a relation with a limit" do
    expect { User.limit(1).each {} }.to_not raise_error
  end

  it "does not raise an error when iterating over a relation with an in clause" do
    expect { User.where(id: [1, 2, 3]).each {} }.to_not raise_error
  end

  it "does not raise an error when iterating over a relation with an in clause and a limit" do
    expect { User.where(id: [1, 2, 3]).limit(1).each {} }.to_not raise_error
  end
end
