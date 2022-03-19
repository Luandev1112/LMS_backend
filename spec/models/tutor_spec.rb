require 'rails_helper'

describe Tutor do

  describe '#search' do

    describe "Searching various availabilities" do

      let!(:ts) { create_list :tutor, 3 }
      let!(:a1) { create :availability, name: 'morning' }
      let!(:a2) { create :availability, name: 'evening' }
      let!(:t1a1) { create :tutor_availability, tutor: ts[0], availability: a1 }
      let!(:t2a2) { create :tutor_availability, tutor: ts[1], availability: a2 }
      let!(:t3a1) { create :tutor_availability, tutor: ts[2], availability: a1 }
      let!(:t3a2) { create :tutor_availability, tutor: ts[2], availability: a2 }

      before do
        ts.each_with_index do |tutor, i|
          tutor.update updated_at: i.days.ago
        end
      end

      context "availabilities key totally absent" do
        it "returns all three tutors" do
          expect(Tutor.search({})).to eq [ts[0], ts[1], ts[2]]
        end
      end

      context "availabilities key present but empty" do
        it "returns no tutors" do
          expect(Tutor.search({ availabilities: [] })).to eq []
        end
      end

      context "availabilities=[morning]" do
        it "returns tutors 1 and 3" do
          expect(Tutor.search({ availabilities: [a1.id] })).to eq [ts[0], ts[2]]
        end
      end

      context "availabilities=[evening]" do
        it "returns tutors 2 and 3" do
          expect(Tutor.search({ availabilities: [a2.id] })).to eq [ts[1], ts[2]]
        end
      end

      context "availabilities=[morning, evening]" do
        it "returns all three tutors" do
          expect(Tutor.search({ availabilities: [a1.id, a2.id] })).to eq [ts[0], ts[1], ts[2]]
        end
      end
    end

    describe "Searching various hourly rates, tutors have rate 10, 15, 20, 25, 30" do

      let!(:t10) { create :tutor, hourly_rate: 10.00 }
      let!(:t15) { create :tutor, hourly_rate: 15.00 }
      let!(:t20) { create :tutor, hourly_rate: 20.00 }
      let!(:t25) { create :tutor, hourly_rate: 25.00 }
      let!(:t30) { create :tutor, hourly_rate: 30.00 }

      before do
        [t10, t15, t20, t25, t30].each_with_index do |tutor, i|
          tutor.update updated_at: Time.current - (i+1).day
        end
      end

      context "rates key is absent" do
        it "returns all five tutors" do
          expect(Tutor.search({})).to eq [t10, t15, t20, t25, t30]
        end
      end

      context "rates key is present but empty" do
        it "returns all five tutors" do
          expect(Tutor.search({ rate: {} })).to eq [t10, t15, t20, t25, t30]
        end
      end

      context "rates key has low=0" do
        it "returns all five tutors" do
          expect(Tutor.search({ rate: { low: 0 }})).to eq [t10, t15, t20, t25, t30]
        end
      end

      context "rates key has low=24.43" do
        it "returns only t25 and t30" do
          expect(Tutor.search({ rate: { low: 24.43 }})).to eq [t25, t30]
        end
      end

      context "rates key has low=1224123.32" do
        it "returns no tutors" do
          expect(Tutor.search({ rate: { low: 1224123.32 }})).to eq []
        end
      end

      context "rates key has high=0" do
        it "returns no tutors" do
          expect(Tutor.search({ rate: { high: 0 }})).to eq []
        end
      end

      context "rates key has high=14.55" do
        it "returns only t10" do
          expect(Tutor.search({ rate: { high: 14.55 }})).to eq [t10]
        end
      end

      context "rates key has high=43.33" do
        it "returns all five tutors" do
          expect(Tutor.search({ rate: { high: 43.33 }})).to eq [t10, t15, t20, t25, t30]
        end
      end

      context "rates key has low=3.20 and high=28.76" do
        it "returns all five tutors" do
          expect(Tutor.search({ rate: { low: 3.20, high: 28.76 }})).to eq [t10, t15, t20, t25]
        end
      end

      context "rates key has low=13.20 and high=18.76" do
        it "returns only t15" do
          expect(Tutor.search({ rate: { low: 13.20, high: 18.76 }})).to eq [t15]
        end
      end
    end


    describe "Searching various postcodes and distances" do

      # A rectangular grid of postcodes, and one tutor per postcode.
      # Note: 1 degree at the Equator is ~111km.
      let!(:p00) { create :postcode, code: '0000', latitude: 0, longitude: 0 }
      let!(:p01) { create :postcode, code: '0101', latitude: 0, longitude: 1 }
      let!(:p30) { create :postcode, code: '3030', latitude: 3, longitude: 0 }
      let!(:p31) { create :postcode, code: '3131', latitude: 3, longitude: 1 }
      let!(:p60) { create :postcode, code: '6060', latitude: 6, longitude: 0 }
      let!(:p61) { create :postcode, code: '6161', latitude: 6, longitude: 1 }
      let!(:p90) { create :postcode, code: '9090', latitude: 9, longitude: 0 } 
      let!(:p91) { create :postcode, code: '9191', latitude: 9, longitude: 1 }
      let!(:t00) { create :tutor, postcode: p00 }
      let!(:t01) { create :tutor, postcode: p01 }
      let!(:t30) { create :tutor, postcode: p30 }
      let!(:t31) { create :tutor, postcode: p31 }
      let!(:t60) { create :tutor, postcode: p60 }
      let!(:t61) { create :tutor, postcode: p61 }
      let!(:t90) { create :tutor, postcode: p90 }
      let!(:t91) { create :tutor, postcode: p91 }

      before do
        [t00, t01, t30, t31, t60, t61, t90, t91].each_with_index do |tutor, i|
          tutor.update updated_at: Time.now - (i+2).day
        end
      end

      context "Supplying the postcode for p31" do
 
        context "Supplying a distance" do

          context "Distance=10km" do
            it "returns only the tutor on the supplied postcode, ordered by distance, then updated_at" do
              query = Tutor.search({ postcode: p31.code, distance: 10 })
              expect(query).to eq [t31]
            end
          end

          context "Distance=120km" do
            it "returns the same tutor and its nearest neighbour, ordered by distance, then updated_at" do
              query = Tutor.search({ postcode: p31.code, distance: 120 })
              expect(query).to eq [t31, t30]
            end
          end

          context "Distance=360km" do 
            it "returns the same tutor and its five nearest neighbours, ordered by distance, then updated_at" do
              query = Tutor.search({ postcode: p31.code, distance: 360 })
              expect(query).to eq [t31, t30, t01, t61, t60, t00]
            end
          end

          context "Distance=1000km" do 
            it "returns the same tutor and its seven nearest neighbours, ordered by distance, then updated_at" do
              query = Tutor.search({ postcode: p31.code, distance: 1000 })
              expect(query).to eq [t31, t30, t01, t61, t60, t00, t91, t90]
            end
          end
        end

        context "Not supplying a distance" do
          it "returns the same tutor and its seven nearest neighbours, ordered by distance, then updated_at" do
            query = Tutor.search({ postcode: p31.code })
            expect(query).to eq [t31, t30, t01, t61, t60, t00, t91, t90]
          end
        end
      end
    end

    describe "searching various subjects" do

      let!(:s1) { create :subject }
      let!(:s2) { create :subject }
      let!(:s3) { create :subject }
      let!(:s4) { create :subject }
      let!(:t1) { create :tutor }
      let!(:t2) { create :tutor }
      let!(:t3) { create :tutor }
      let!(:t4) { create :tutor }
      let!(:s1t1) { create :subject_tutor, subject: s1, tutor: t1 }
      let!(:s1t3) { create :subject_tutor, subject: s1, tutor: t3 }
      let!(:s1t4) { create :subject_tutor, subject: s1, tutor: t4 }
      let!(:s2t3) { create :subject_tutor, subject: s2, tutor: t3 }
      let!(:s3t3) { create :subject_tutor, subject: s3, tutor: t3 }
      let!(:s3t1) { create :subject_tutor, subject: s3, tutor: t1 }
      let!(:s3t2) { create :subject_tutor, subject: s3, tutor: t2 }
      let!(:s4t4) { create :subject_tutor, subject: s4, tutor: t4 }

      before do
        [t1, t2, t3, t4].each_with_index do |tutor, i|
          tutor.update updated_at: Time.now - (i+2).days
        end
      end

      context "Not supplying any subject key" do
        it "returns all four tutors" do
          expect(Tutor.search({})).to eq [t1, t2, t3, t4]
        end
      end

      context "Supplying a subject key with no entries" do
        it "returns no tutors" do
          expect(Tutor.search({ subjects: [] })).to eq []
        end
      end

      context "Supplying subjects=[s1]" do
        it "returns t1, t3, t4" do
          expect(Tutor.search({ subjects: [s1.id] })).to eq [t1, t3, t4]
        end
      end

      context "Supplying subjects=[s1,s3]" do
        it "returns all four tutors" do
          expect(Tutor.search({ subjects: [s1.id, s3.id] })).to eq [t1, t2, t3, t4]
        end
      end

      context "Supplying subjects=[s2,s4]" do
        it "returns t3, t4" do
          expect(Tutor.search({ subjects: [s2.id, s4.id] })).to eq [t3, t4]
        end
      end

      context "Supplying subjects=[s1,s2,s3,s4]" do
        it "returns all four tutors" do
          expect(Tutor.search({ subjects: [s1.id, s2.id, s3.id, s4.id] })).to eq [t1, t2, t3, t4]
        end
      end
    end

    describe "searching various languages" do

      let!(:l1) { create :language }
      let!(:l2) { create :language }
      let!(:l3) { create :language }
      let!(:l4) { create :language }
      let!(:t1) { create :tutor }
      let!(:t2) { create :tutor }
      let!(:t3) { create :tutor }
      let!(:t4) { create :tutor }
      let!(:l1u1) { create :language_user, language: l1, user: t1 }
      let!(:l1u3) { create :language_user, language: l1, user: t3 }
      let!(:l1u4) { create :language_user, language: l1, user: t4 }
      let!(:l2u3) { create :language_user, language: l2, user: t3 }
      let!(:l3u3) { create :language_user, language: l3, user: t3 }
      let!(:l3u1) { create :language_user, language: l3, user: t1 }
      let!(:l3u2) { create :language_user, language: l3, user: t2 }
      let!(:l4u4) { create :language_user, language: l4, user: t4 }

      before do
        [t1, t2, t3, t4].each_with_index do |tutor, i|
          tutor.update updated_at: Time.now - (i+2).days
        end
      end

      context "Not supplying any language key" do
        it "returns all four tutors" do
          expect(Tutor.search({})).to eq [t1, t2, t3, t4]
        end
      end

      context "Supplying a language key with no entries" do
        it "returns no tutors" do
          expect(Tutor.search({ languages: [] })).to eq []
        end
      end

      context "Supplying languages=[l1]" do
        it "returns t1, t3, t4" do
          expect(Tutor.search({ languages: [l1.id] })).to eq [t1, t3, t4]
        end
      end

      context "Supplying languages=[l1,l3]" do
        it "returns all four tutors" do
          expect(Tutor.search({ languages: [l1.id, l3.id] })).to eq [t1, t2, t3, t4]
        end
      end

      context "Supplying languages=[l2,l4]" do
        it "returns t3, t4" do
          expect(Tutor.search({ languages: [l2.id, l4.id] })).to eq [t3, t4]
        end
      end

      context "Supplying languages=[l1,l2,l3,l4]" do
        it "returns all four tutors" do
          expect(Tutor.search({ languages: [l1.id, l2.id, l3.id, l4.id] })).to eq [t1, t2, t3, t4]
        end
      end
    end


    describe "Searching various page sizes" do

      before {
        create_list :tutor, 22
      }

      context "page_size totally absent" do
        it { expect(Tutor.search({}).length).to eq 20 }
      end

      context "page_size=5" do
        it { expect(Tutor.search({ page_size: 5 }).length).to eq 5 }
      end

      context "page_size=10" do
        it { expect(Tutor.search({ page_size: 10 }).length).to eq 10 }
      end

      context "page_size=15" do
        it { expect(Tutor.search({ page_size: 15 }).length).to eq 15 }
      end

      context "page_size=25" do
        it { expect(Tutor.search({ page_size: 25 }).length).to eq 22 }
      end
    end

    describe "Searching various page numbers" do

      let!(:t1) { create :tutor }
      let!(:t2) { create :tutor }
      let!(:t3) { create :tutor }
      let!(:t4) { create :tutor }
      let!(:t5) { create :tutor }
      let!(:t6) { create :tutor }
      let!(:t7) { create :tutor }
      let!(:t8) { create :tutor }
      let!(:t9) { create :tutor }
      let!(:t10) { create :tutor }
      let!(:t11) { create :tutor }

      before do
        [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11].each_with_index do |tutor, i|
          tutor.update updated_at: Time.now - (i+1).day
        end
      end

      it { expect(Tutor.search({ page_size: 2 })).to eq [t1, t2] }
      it { expect(Tutor.search({ page_size: 2, page_number: 0 })).to eq [t1, t2] }
      it { expect(Tutor.search({ page_size: 2, page_number: 1 })).to eq [t3, t4] }
      it { expect(Tutor.search({ page_size: 2, page_number: 2 })).to eq [t5, t6] }
      it { expect(Tutor.search({ page_size: 2, page_number: 3 })).to eq [t7, t8] }
      it { expect(Tutor.search({ page_size: 2, page_number: 4 })).to eq [t9, t10] }
      it { expect(Tutor.search({ page_size: 2, page_number: 5 })).to eq [t11] }
      it { expect(Tutor.search({ page_size: 2, page_number: 6 })).to eq [] }
    end

  end

end

